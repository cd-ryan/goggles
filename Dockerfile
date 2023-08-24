FROM python:slim
RUN apt-get update && \
    apt-get install -y git python3-tldextract python3-requests python3-flask && \
    apt-get clean && \
    mkdir /root/.ssh && \
    chmod 0700 /root/.ssh
COPY . /app
RUN mv /app/id_rsa /root/.ssh/id_rsa && \
    mv /app/known_hosts /root/.ssh/known_hosts && \
    mv /app/.gitconfig /root/.gitconfig && \
    chmod 0400 /root/.ssh/id_rsa && \
    chmod 0644 /root/.ssh/known_hosts && \
    chmod 0664 /root/.gitconfig
WORKDIR /app
EXPOSE 5000
CMD flask run --host=0.0.0.0

