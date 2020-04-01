{ lib, python3, mautrix-facebook }:

with python3.pkgs;

buildPythonPackage rec {
  pname = "mautrix-facebook";
  version = "0.1.0.dev15";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0k4q9d2dhmw6pdp9qlgwvki4qn27nk9n3kk2y0fcbpvp3c7x6ci6";
  };

  postPatch = ''
    sed -i -e '/alembic>/d' setup.py
  '';

  propagatedBuildInputs = 
   let 
    tulir-hbmqtt = buildPythonPackage rec {
       pname = "tulir-hbmqtt";
       version = "0.9.6.dev20191123131128";
      
       src = fetchPypi {
         inherit pname version;
         sha256 = "0xrla3nc99hnvxp70gz9f6mmh1mlb92sdggdb2j5bflwap2g58l7";
       };
      
       propagatedBuildInputs = [
         transitions
         passlib
         websockets
         pyyaml
         docopt
         setuptools
       ];
       doCheck = false;
       disabled = pythonOlder "3.5";
       meta = with lib; {
         homepage = https://github.com/beerfactory/hbmqtt;
         description = "MQTT client/broker using Python 3.4 asyncio library";
         license = licenses.mit;
       };
     };
    fbchat-asyncio = buildPythonPackage rec {
       pname = "fbchat-asyncio";
       version = "0.3.0";
      
       src = fetchPypi {
         inherit pname version;
         sha256 = "0z5jkyi864gz7hp6d7nam04nhz8p25r58k512bpgjdskg498cgm4";
       };
      
       propagatedBuildInputs = [
         tulir-hbmqtt
         python_magic
         beautifulsoup4
         aiohttp
         aenum
       ];
       #doCheck = false;
       disabled = pythonOlder "3.5";
       meta = with lib; {
         homepage = https://github.com/tulir/fbchat-asyncio;
         description = "Facebook Messenger library for Python/Asyncio";
         license = licenses.bsd3;
       };
     };
      
   in [
   aiohttp
   fbchat-asyncio
   mautrix
   ruamel_yaml
  ];

  # No tests available
  doCheck = false;

  # `alembic` (a database migration tool) is only needed for the initial setup,
  # and not needed during the actual runtime. However `alembic` requires `mautrix-facebook`
  # in its environment to create a database schema from all models.
  #
  # Hence we need to patch away `alembic` from `mautrix-facebook` and create an `alembic`
  # which has `mautrix-facebook` in its environment.
  passthru.alembic = alembic.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      mautrix-facebook
    ];
  });

  checkInputs = [
    pytest
    pytestrunner
    pytest-mock
    pytest-asyncio
  ];

  meta = with lib; {
    homepage = https://github.com/tulir/mautrix-facebook;
    description = "A Matrix-Facebook Messenger puppeting bridge";
    license = licenses.agpl3Plus;
  };
}
