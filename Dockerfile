FROM python:3.10-slim

ARG TESTING=0

# make sure it doesnt fail if the docker file doesnt know the git commit
ARG GIT_PYTHON_REFRESH=quiet

# install extra requirements
RUN apt-get clean
RUN apt-get update -y
RUN apt-get install gcc g++ cmake libgeos-dev -y git -y pkg-config -y libhdf5-dev

# Install XGBoost 2.0.0, which has quantile regression. Once this is released, these two lines should be removed
RUN git clone --recursive https://github.com/dmlc/xgboost
RUN cd xgboost && git checkout 603f8ce2fa71eecedadd837316dcac95ab7f4ff7 && mkdir build && cd build && cmake .. && make -j4 && cd .. && cd python-package && pip install .

# copy files
COPY setup.py app/setup.py
COPY README.md app/README.md
COPY requirements.txt app/requirements.txt

# install requirements
RUN pip install -r app/requirements.txt

# copy library files
COPY gradboost_pv/ app/gradboost_pv/
COPY data/ app/data/
COPY tests/ app/tests/
COPY configs/ app/configs/

# change to app folder
WORKDIR /app

# install library
RUN pip install -e .

RUN if [ "$TESTING" = 1 ]; then pip install pytest pytest-cov coverage; fi

CMD ["python", "-u","gradboost_pv/app.py"]
