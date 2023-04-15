FROM python:3.9 as build-backend
#PYTHONDONTWRITEBYTECODE=1 \
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN pip install -U pip setuptools wheel && \
    pip install poetry
#中国网络打开源
#RUN pip install -U pip setuptools wheel -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com && \
#    pip install poetry
WORKDIR /app/backend
ENV POETRY_VIRTUALENVS_IN_PROJECT=true

COPY backend/pyproject.toml backend/poetry.lock ./
COPY backend/ app/
#中国网络打开源
#COPY  poetry.toml ./
RUN ls -a /app/backend/

RUN poetry install --no-dev





FROM node:16 as build-frontend

WORKDIR /app/frontend

COPY frontend/package.json frontend/*.config.js frontend/yarn.lock ./
RUN yarn install

COPY frontend/src src/
COPY frontend/public public/

RUN yarn build


FROM nginx/unit:1.26.1-python3.9

WORKDIR /app

COPY --from=build-backend /app/backend/ backend
COPY --from=build-frontend /app/frontend/dist frontend

COPY docker/config.json /docker-entrypoint.d/config.json

