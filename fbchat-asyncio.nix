{ lib, python3 }:

with python3.pkgs;

buildPythonPackage rec {
  pname = "fbchat-asyncio";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0z5jkyi864gz7hp6d7nam04nhz8p25r58k512bpgjdskg498cgm4";
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
