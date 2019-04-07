var webpack = require('webpack');

module.exports = {
	entry: './src/index.ls',
	mode: 'production',
	output: {
		path: __dirname + '/build',
		filename: 'index.min.js'
	},
	module: {
		rules: [
			{ test: /\.ls$/, use: 'livescript-loader' },
			{ test: /\.jade$/, use: 'jade-loader' },
			{ test: /\.svg$/, use: 'url-loader?limit=0' },
			{ test: /\.styl$/, use: [
				'style-loader',
				'css-loader',
				'stylus-loader'
			]}
		]
	},
	devtool: 'source-map'
};
