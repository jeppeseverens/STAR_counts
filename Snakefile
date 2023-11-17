import os
import subprocess
from functools import partial
from os.path import dirname
from uuid import uuid4

include: "includes/expression/Snakefile"

settings=config["settings"]

PIPELINE_VERSION = "v1"

RUN_NAME = settings.get("run_name") or f"hamlet-{uuid4().hex[:8]}"

rule all:
    input:
        count_fragments_per_gene=expand("{sample}/expression/ReadsPerGene.out.tab", sample=config["samples"])

