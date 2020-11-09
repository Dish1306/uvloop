#!/bin/bash

set -e -x

# Compile wheels
PYTHON="/opt/python/${PYTHON_VERSION}/bin/python"
PIP="/opt/python/${PYTHON_VERSION}/bin/pip"
${PIP} install -r /io/.ci/requirements.txt
make -C /io/ PYTHON="${PYTHON}" ci-clean compile
${PIP} wheel /io/ -w /io/dist/

# Bundle external shared libraries into the wheels.
for whl in /io/dist/*.whl; do
    if [ `uname -m` == 'aarch64' ] ; then
     echo "inside aarch64"
     auditwheel repair --plat="manylinux2014_${PYARCH}" \
                $whl -w /io/dist/
     rm /io/dist/*-linux_*.whl
    else
     auditwheel repair --plat="manylinux2010_${PYARCH}" \
                $whl -w /io/dist/
         rm /io/dist/*-linux_*.whl
    fi
done

PYTHON="/opt/python/${PYTHON_VERSION}/bin/python"
PIP="/opt/python/${PYTHON_VERSION}/bin/pip"
${PIP} install ${PYMODULE} --no-index -f file:///io/dist
rm -rf /io/tests/__pycache__
make -C /io/ PYTHON="${PYTHON}" testinstalled
rm -rf /io/tests/__pycache__
