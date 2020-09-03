{ pkgs, lib, python3, mautrix-facebook }:

with python3.pkgs;

buildPythonPackage rec {
  pname = "mautrix-facebook";
  version = "0.1.0rc1";

  #src = fetchPypi {
    #inherit pname version;
    #sha256 = "1pm65x2g9pa37y47fik28n9h3l608yrvsr74n9h2djkcrqvhl9y2";
  #};
	src = pkgs.fetchFromGitHub {
		owner = "tulir";
		repo = "mautrix-facebook";
		rev = "a3cf57bfd29cd6d1e8a4ed09553319c6403c0a90";
		sha256 = "0qcf5zsjj02p7h3f344hhsqn90315bih2rh9m3wkr36wl2xkgvqg";
	};

  postPatch = ''
    sed -i -e '/alembic>/d' setup.py
    sed -i -e '/alembic>/d' requirements.txt
  '';

  propagatedBuildInputs = 
   let 
    my_mautrix = pkgs.callPackage /home/nathan/vim_config/mautrix.nix { };
    #tulir-hbmqtt = buildPythonPackage rec {
       #pname = "tulir-hbmqtt";
       #version = "0.9.7.dev20200404232413";
      
       #src = fetchPypi {
         #inherit pname version;
         #sha256 = "1nprmrwlxz8j1rz1q45kvzawfa775bgy6ca1gmjh1cd3vgkcjpq4";
       #};
      
       #propagatedBuildInputs = [
         #transitions
         #passlib
         #websockets
         #pyyaml
         #docopt
         #setuptools
       #];
       #doCheck = false;
       #disabled = pythonOlder "3.5";
       #meta = with lib; {
         #homepage = https://github.com/beerfactory/hbmqtt;
         #description = "MQTT client/broker using Python 3.4 asyncio library";
         #license = licenses.mit;
       #};
     #};
    paho-mqtt = buildPythonPackage rec {
       pname = "paho-mqtt";
       version = "1.5.0";
      
       src = fetchPypi {
         inherit pname version;
         sha256 = "1r2b7433hixppmwigz072l7ap8r53na23hividf1ksmaiccqdlp3";
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
       version = "0.6.0b3";
      
       src = fetchPypi {
         inherit pname version;
         sha256 = "0y26cp7md5rjl2g2c01q7608l2rr1iprcpgva9qc9dgpmsqw4y0a";
       };
      
       propagatedBuildInputs = [
         #tulir-hbmqtt
         paho-mqtt
         python_magic
         beautifulsoup4
         aiohttp
         aenum
       ];
      postPatch = '' sed -i -e 's/paho.mqtt/paho-mqtt/g' setup.py '';
       doCheck = false;
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
   #mautrix
   my_mautrix
   ruamel_yaml
   sqlalchemy
   CommonMark
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
