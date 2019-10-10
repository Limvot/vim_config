{ lib, python3, mautrix, fbchat-asyncio, mautrix-facebook }:

with python3.pkgs;

buildPythonPackage rec {
  pname = "mautrix-facebook";
  version = "0.1.0.dev12";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1asq87sl1154k3vvwxn0f9lshydhd41in1lwr6ckz57gbnsnamyj";
  };

  postPatch = ''
    sed -i -e '/alembic>/d' setup.py
  '';

  propagatedBuildInputs = [
    Mako
    aiohttp
    fbchat-asyncio
    mautrix
    sqlalchemy
    CommonMark
    ruamel_yaml
    future-fstrings
    python_magic
    telethon
    telethon-session-sqlalchemy
    pillow
    lxml
    setuptools
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
