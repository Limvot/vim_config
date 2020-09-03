#{ lib, buildPythonPackage, fetchPypi, aiohttp, future-fstrings, pythonOlder, attrs }:
{ lib, python3 }:

with python3.pkgs;

buildPythonPackage rec {
  pname = "mautrix";
  version = "0.5.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1aac5f5fvff0hwbi819qify23n4mdyhs3c27ab1cdhb26mngip58";
  };

  propagatedBuildInputs = [
    aiohttp
    attrs
  ];

  # No tests available
  doCheck = false;

  disabled = pythonOlder "3.5";

  meta = with lib; {
    homepage = https://github.com/tulir/mautrix-python;
    description = "A Python 3 asyncio-based Matrix framework";
    license = licenses.mit;
    #maintainers = with maintainers; [ nyanloutre ];
  };
}
