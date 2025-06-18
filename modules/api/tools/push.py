import json
import subprocess
import sys
import tomllib
from pathlib import Path

project_root = Path(__file__).resolve().parent.parent
pyproject_path = project_root / "pyproject.toml"

with open(pyproject_path, "rb") as f:
    pyproject = tomllib.load(f)

try:
    config = pyproject["tool"]["neo4j-api"]
    version_tag = pyproject["project"]["version"]
except KeyError as e:
    print(f"Missing required config in pyproject.toml: {e}", file=sys.stderr)
    sys.exit(1)

image_uri = (
    f"{config['region']}-docker.pkg.dev/"
    f"{config['project']}/"
    f"{config['repo']}/"
    f"{config['image']}:{version_tag}"
)


def run(cmd):
    print(f"Executing: {cmd}")
    subprocess.run(cmd, shell=True, check=True)


run(f"docker buildx build --platform linux/amd64 -t {image_uri} --push -f {project_root}/Dockerfile {project_root}")

print(f"Image pushed: {image_uri}")

version_file = project_root.parent.parent / "image_tag.auto.tfvars.json"
with open(version_file, "w") as f:
    json.dump({"image_tag": version_tag}, f, indent=2)
    print(f"Terraform image tag written to: {version_file}")
