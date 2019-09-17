{ lib, fetchPypi, buildPythonPackage, isPy36, isPy37, routerFeatures
, janus, ncclient, paramiko, pyyaml, sanic }:

let
  # The `routerFeatures` flag optionally brings in some somewhat heavy
  # dependencies, in order to enable interacting with routers
  opts = if routerFeatures then {
      prePatch = ''
        substituteInPlace ./setup.py --replace "extra_deps = []" "extra_deps = router_feature_deps"
      '';
      extraBuildInputs = [ janus ncclient paramiko ];
    } else {
      prePatch = "";
      extraBuildInputs = [];
    };

in

buildPythonPackage rec {
  pname = "entrance";
  version = "1.1.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0djhr75vs516wzwp4da3yfsnapb6nfwhz7mirb0g9jlwvpmhkaz9";
  };

  # The package does go back to Python 3.5 via some contortions (since later versions
  # of `sanic` dropped support for 3.5), but don't bother with those here.
  disabled = !(isPy36 || isPy37);

  # No useful tests
  doCheck = false;

  propagatedBuildInputs = [ pyyaml sanic ] ++ opts.extraBuildInputs;

  prePatch = opts.prePatch;

  meta = with lib; {
    description = "A server framework for web apps with an Elm frontend";
    homepage = https://github.com/ensoft/entrance;
    license = licenses.mit;
    maintainers = with maintainers; [ simonchatts ];
  };
}

