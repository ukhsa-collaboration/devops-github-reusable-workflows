const fs = require('fs');
const path = require('path');

const environment = "${{ inputs.environment_name }}";
const stack = "${{ steps.variables.outputs.state_name }}";

try {
  const issue_number = context.payload.pull_request.number;
  const owner = context.repo.owner;
  const repo = context.repo.repo;
  const commentIdentifier = `<!-- planComment-${environment}-${stack} -->`;
  const filePath = path.join(process.env.GITHUB_WORKSPACE, environment, stack, 'tfplan.json');

  if (!fs.existsSync(filePath)) {
    console.log(`❌ Terraform plan file not found: ${filePath}`);
    core.setFailed('Terraform plan file not found.');
    return;
  }

  const fileContent = fs.readFileSync(filePath, 'utf8');

  let planJson;
  try {
    planJson = JSON.parse(fileContent);
  } catch (parseError) {
    core.setFailed(`Failed to parse tfplan.json: ${parseError.message}`);
    return;
  }

  const summary = { create: [], update: [], delete: [], replace: [] };

  const changes = planJson.resource_changes || [];
  changes.forEach(change => {
    const address = change.address;
    const actions = change.change.actions;
    // If the actions include both delete and create, it's a replacement.
    if (actions.includes("delete") && actions.includes("create")) {
      summary.replace.push(address);
    } else if (actions.includes("create")) {
      summary.create.push(address);
    } else if (actions.includes("update")) {
      summary.update.push(address);
    } else if (actions.includes("delete")) {
      summary.delete.push(address);
    }
  });

  let summaryText = `### Terraform Plan Summary (${environment.toUpperCase()}/${stack.toUpperCase()})\n\n`;
  if (summary.delete.length > 0) {
    summaryText += `🔴 **Resources to be destroyed:**\n${summary.delete.map(addr => `- ${addr}`).join("\n")}\n\n`;
  }
  if (summary.update.length > 0) {
    summaryText += `🟡 **Resources to be updated:**\n${summary.update.map(addr => `- ${addr}`).join("\n")}\n\n`;
  }
  if (summary.create.length > 0) {
    summaryText += `🟢 **Resources to be created:**\n${summary.create.map(addr => `- ${addr}`).join("\n")}\n\n`;
  }
  if (summary.replace.length > 0) {
    summaryText += `🟣 **Resources to be replaced:**\n${summary.replace.map(addr => `- ${addr}`).join("\n")}\n\n`;
  }
  if (summary.update.length == 0 && summary.delete.length == 0 && summary.create.length == 0 && summary.replace.length == 0) {
    summaryText += `👌 **No resources will be changed**\n\n`;
    // This block of code should be unreachable because planned_changes should be false and this
    // Github Actions step should be skipped.
  }

  // Append the comment identifier so that subsequent runs can update the correct comment.
  summaryText += commentIdentifier;

  const comments = await github.rest.issues.listComments({
    owner,
    repo,
    issue_number,
  });

  const botComment = comments.data.find(comment => comment.body.includes(commentIdentifier));

  if (botComment) {
    await github.rest.issues.updateComment({
      owner,
      repo,
      comment_id: botComment.id,
      body: summaryText,
    });
    console.log(`✅ Updated existing PR comment for environment: ${environment} / stack: ${stack}`);
  } else {
    await github.rest.issues.createComment({
      owner,
      repo,
      issue_number,
      body: summaryText,
    });
    console.log(`✅ Created a new PR comment for environment: ${environment} / stack: ${stack}`);
  }
} catch (error) {
  core.setFailed(`🚨 Failed to comment on PR for environment ${environment}: ${error.message}`);
}