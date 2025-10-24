from app import hello


def test_hello_returns_expected_message() -> None:
    assert hello() == "hello from container image build workflow"
