{ lib, python3, mautrix-facebook, fetchFromGitHub, ... }:

with python3.pkgs;

let
  # officially supported database drivers
  dbDrivers = [
    psycopg2
    # sqlite driver is already shipped with python by default
  ];

  fbchat-asyncio = buildPythonPackage rec {
      pname = "fbchat-asyncio";
      version = "0.6.20";

      src = fetchPypi {
          inherit pname version;
          sha256 = "1n50wp79j3zj700sv0ivyjnrqfzkg2pqc2z4br9bfxakkkmfyfgd";
      };

      propagatedBuildInputs = [
          paho-mqtt
          beautifulsoup4
          aiohttp
          yarl
      ];
      doCheck = false;
      disabled = pythonOlder "3.5";
      meta = with lib; {
          homepage = https://github.com/tulir/fbchat-asyncio;
          description = "Facebook Messenger library for Python/Asyncio";
          license = licenses.bsd3;
      };
  };

in buildPythonPackage rec {
  pname = "mautrix-facebook";
  version = "0.1.1";
  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "tulir";
    repo = pname;
    rev = "v${version}";
    sha256 = "0y9w5frl2ib6g7jl6sjdxw6pknlpkp697aqdq74hxibfkjh0mkfi";
  };

  patches = [ ./mautrix-facebook-bin.patch ];
  postPatch = ''
    sed -i -e '/alembic>/d' requirements.txt
  '';

  nativeBuildInputs = [
    pytestrunner
  ];

  propagatedBuildInputs = [
    aiohttp
    yarl
    mautrix
    sqlalchemy
    CommonMark
    ruamel_yaml
    python_magic
    fbchat-asyncio
    setuptools
  ] ++ dbDrivers;

  # `alembic` (a database migration tool) is only needed for the initial setup,
  # and not needed during the actual runtime. However `alembic` requires `mautrix-facebok`
  # in its environment to create a database schema from all models.
  #
  # Hence we need to patch away `alembic` from `mautrix-facebook` and create an `alembic`
  # which has `mautrix-facebook` in its environment.
  passthru.alembic = alembic.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ dbDrivers ++ [
      mautrix-facebook
    ];
  });

  # Tests are broken and throw the following for every test:
  #   TypeError: 'Mock' object is not subscriptable
  doCheck = false;

  checkInputs = [
    pytest
    pytest-mock
    pytest-asyncio
  ];

  meta = with lib; {
    homepage = "https://github.com/tulir/mautrix-facebook";
    description = "A Matrix-Messenger hybrid puppeting/relaybot bridge";
    license = licenses.agpl3Plus;
    platforms = platforms.linux;
  };
}
