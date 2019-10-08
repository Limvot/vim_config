{ lib, python3 }:

with python3.pkgs;

buildPythonPackage rec {
  pname = "fbchat-asyncio";
  version = "0.2.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1sjp6hwfzzjfkq6dlxhdlbd0iwq736kv8d4f4w1zqk0dq7b91lgr";
  };

  propagatedBuildInputs = [
    beautifulsoup4
    aiohttp
    aenum
    #attrs
  ];

  # No tests available
  #doCheck = false;

  disabled = pythonOlder "3.5";

  meta = with lib; {
    homepage = https://github.com/tulir/fbchat-asyncio;
    description = "Facebook Messenger library for Python/Asyncio";
    license = licenses.bsd3;
    #maintainers = with maintainers; [ nyanloutre ];
  };
}
