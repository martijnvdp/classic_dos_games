FROM node:18-alpine AS jsdos
RUN wget https://js-dos.com/6.22/current/js-dos.js && \
    wget https://js-dos.com/6.22/current/wdosbox.js && \
    wget https://js-dos.com/6.22/current/wdosbox.wasm.js
RUN npm install -g serve
ARG GAME_URL
RUN wget -O game.zip "$GAME_URL"
ARG GAME_ARGS
ARG GAME_DIR
ARG GAME_NAME
COPY index.html media/bg.jpg ./
RUN sed -i s/GAME_DIR/$GAME_DIR/ index.html
RUN sed -i s/GAME_ARGS/\"$GAME_ARGS\"/ index.html
RUN sed -i s/GAME_TITLE/$GAME_NAME/ index.html

ENTRYPOINT ["npx", "serve", "-l", "tcp://0.0.0.0:8000"]