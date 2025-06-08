module.exports = {
  presets: [
    '@vue/cli-plugin-babel/preset'
  ],
  plugins: [
    // Enables support for class properties (optional, but useful for modern JS)
    '@babel/plugin-proposal-class-properties',
    // Transforms private class methods so that they work in older environments
    '@babel/plugin-transform-private-methods',
    // Reuses Babel helper code to reduce bundle size
    ['@babel/plugin-transform-runtime', { requireConfigFile: false }]
  ]
};
