FROM python:3.10-bullseye
RUN pip install flask
COPY leaker.py /app/leaker.py
WORKDIR /app
CMD ["python", "leaker.py"]