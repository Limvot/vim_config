#{ lib, buildPythonPackage, fetchPypi, aiohttp, future-fstrings, pythonOlder, attrs }:
{ lib, python3 }:

with python3.pkgs;

buildPythonPackage rec {
  pname = "mautrix";
  version = "0.4.0.dev72";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1kbq4g39i3n6w12g15k72jg1sk5g5rzs1hx9asnrqy1972817whz";
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
