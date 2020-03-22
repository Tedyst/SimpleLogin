# Install npm packages
FROM node:10.17.0-alpine AS npm
WORKDIR /code
COPY ./static/package*.json /code/static/
RUN cd /code/static && npm install


FROM python:3.7
WORKDIR /code

# Added piwheels to make the builds faster for Raspberry PI
ARG TARGETPLATFORM
RUN if [ "$TARGETPLATFORM" = "linux/arm/v7" ] || [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
    printf "[global]\nextra-index-url=https://www.piwheels.org/simple" | touch /etc/pip.conf; \
    fi

# install dependencies
COPY ./requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

# copy npm packages
COPY --from=npm /code /code

# copy everything else into /code
COPY . .

EXPOSE 7777

#gunicorn wsgi:app -b 0.0.0.0:7777 -w 2 --timeout 15 --log-level DEBUG
CMD ["gunicorn","wsgi:app","-b","0.0.0.0:7777","-w","2","--timeout","15"]
