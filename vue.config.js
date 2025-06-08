const { defineConfig } = require('@vue/cli-service');
const dotenv = require('dotenv');
dotenv.config({ path: '../.env' });

module.exports = defineConfig({
  transpileDependencies: [],
  devServer: {
    host: '0.0.0.0'
  }
});
