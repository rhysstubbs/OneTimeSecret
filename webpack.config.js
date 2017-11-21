const webpack = require('webpack'); //to access built-in plugins
const path = require('path');
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const OptimiseCssAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const SpritesmithPlugin = require('webpack-spritesmith');
const CleanupPlugin = require('webpack-cleanup-plugin');

const configuration = {
    devtool: 'source-map',
    node: {
        fs: 'empty'
    },
    entry: {
        app: './public/assets/js/core.js'
    },
    output: {
        path: path.resolve(__dirname, 'public/assets/dist'),
        filename: '[name].bundle.min.js',
        publicPath: '/'
    },
    module: {
        rules: [
            {
                test: /\.scss$/,
                loader: ExtractTextPlugin.extract({
                    fallback: 'style-loader',
                    use: ['css-loader', 'sass-loader']
                })
            },
            {
                test: /\.(eot|svg|ttf|woff|woff2)$/,
                loader: 'file-loader?emitFile=false'
            },
            {
                test: /\.png$/,
                loader: 'file-loader?name=/images/[hash].[ext]'
            }
        ]
    },
    resolve: {
        modules: [
            "node_modules",
            "spritesmith-generated"]
    },
    plugins: [
        new CleanupPlugin(),
        new webpack.ProvidePlugin({
            $: "jquery",
            jQuery: "jquery",
            "window.jQuery": "jquery"
        }),
        new webpack.optimize.CommonsChunkPlugin({
            name: 'vendor',
            filename: '[name].min.js',
            minChunks: function (module) {
                return module.context && (module.context.indexOf('node_modules') !== -1);
            }
        }),
        new webpack.optimize.UglifyJsPlugin({
            parallel: true,
            sourceMap: true,
            minimize: true,
            comments: false
        }),
        new ExtractTextPlugin({
            filename: "[name].min.css",
            allChunks: true
        }),
        new OptimiseCssAssetsPlugin({
            assetNameRegExp: /\.min\.css$/,
            cssProcessor: require('cssnano'),
            cssProcessorOptions: {
                discardComments: {
                    removeAll: true
                },
                preset: 'default',
                map: {
                    inline: false
                }
            },
            canPrint: true
        }),
        new SpritesmithPlugin({
            src: {
                cwd: path.resolve(__dirname, 'public/assets/images/sprites'),
                glob: '*.png'
            },
            target: {
                image: path.resolve(__dirname, 'public/assets/images/sprite.png'),
                css: path.resolve(__dirname, 'public/assets/scss/utilities/sprite.scss')
            },
            retina: '@2x',
            padding: 2
        })
    ]
};

module.exports = configuration;