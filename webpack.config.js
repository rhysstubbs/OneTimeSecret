const production = (process.env.NODE_ENV === 'production' || process.argv.includes('-p'));
const webpack = require('webpack'); //to access built-in plugins
const path = require('path');
const FriendlyErrorsPlugin = require('friendly-errors-webpack-plugin');
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const OptimiseCssAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const SpritesmithPlugin = require('webpack-spritesmith');

/**
 * COMMON CONFIG
 */

let assetPath = '../';
let configuration = {
    context: path.resolve(__dirname),
    entry: {
        '/js/app': [
            path.resolve(__dirname, 'public/assets/js/app.js'),
            path.resolve(__dirname, 'public/assets/scss/app.scss')
        ]
    },
    output: {
        path: path.resolve(__dirname, 'public/assets/dist'),
        filename: '[name].js',
        chunkFilename: '[name].js',
        publicPath: ''
    },
    module: {
        rules: [
            {
                test: /\.css$/,
                exclude: [],
                loaders: ['style-loader', 'css-loader']
            },
            {
                test: /\.s[ac]ss$/,
                exclude: [path.resolve(__dirname, 'public/assets/scss/app.scss')],
                loaders: ['style-loader', 'css-loader', 'sass-loader']
            },
            {
                test: /\.less$/,
                exclude: [],
                loaders: ['style-loader', 'css-loader', 'less-loader']
            },
            {
                test: /\.html$/,
                loaders: ['html-loader']
            },
            {
                test: /\.(png|jpe?g|gif)$/,
                loaders: [
                    {
                        loader: 'file-loader',
                        options: {
                            name: path => {
                                if (! /node_modules|bower_components/.test(path)) {
                                    return 'images/[name].[ext]?[hash]';
                                }

                                return 'images/vendor/' + path
                                    .replace(/\\/g, '/')
                                    .replace(
                                        /((.*(node_modules|bower_components))|images|image|img|assets)\//g, ''
                                    ) + '?[hash]';
                            },
                            publicPath: '../'
                        }
                    },
                    {
                        loader: 'img-loader',
                        options: {
                            enabled: true,
                            gifsicle: {},
                            mozjpeg: {},
                            optipng: {},
                            svgo: {}
                        }
                    }
                ]
            },
            {
                test: /\.(woff2?|ttf|eot|svg|otf)$/,
                loader: 'file-loader',
                options: {
                    name: path => {
                        if (! /node_modules|bower_components/.test(path)) {
                            return 'fonts/[name].[ext]?[hash]';
                        }

                        return 'fonts/vendor/' + path
                            .replace(/\\/g, '/')
                            .replace(
                                /((.*(node_modules|bower_components))|fonts|font|assets)\//g, ''
                            ) + '?[hash]';
                    },
                    publicPath: assetPath
                }
            },
            {
                test: /\.(cur|ani)$/,
                loader: 'file-loader',
                options: {
                    name: '[name].[ext]?[hash]',
                    publicPath: assetPath
                }
            },
            {
                test: path.resolve(__dirname, 'public/assets/scss/app.scss'),
                use: [
                    {
                        loader: require.resolve('extract-text-webpack-plugin/dist/loader.js'),
                        options: {
                            id: 1,
                            omit: 1,
                            remove: true
                        }
                    },
                    {
                        loader: 'style-loader'
                    },
                    {
                        loader: 'css-loader',
                        options: {
                            url: true,
                            sourceMap: false,
                            importLoaders: 1
                        }
                    },
                    {
                        loader: 'resolve-url-loader',
                        options: {
                            sourceMap: true,
                            root: path.resolve(__dirname, 'node_modules')
                        }
                    },
                    {
                        loader: 'sass-loader',
                        options: {
                            precision: 8,
                            outputStyle: 'expanded',
                            sourceMap: true
                        }
                    }
                ]
            }
        ]
    },
    plugins: [
        new ExtractTextPlugin({
            filename: "/css/app.css",
            allChunks: true
        }),
        new FriendlyErrorsPlugin ({
            compilationSuccessInfo: {},
            shouldClearConsole: true
        }),
        new webpack.ProvidePlugin({
            $: "jquery",
            jQuery: "jquery",
            "window.jQuery": "jquery"
        }),
        new webpack.LoaderOptionsPlugin({
            minimize: production
        }),
        new webpack.optimize.CommonsChunkPlugin ({
            name: 'vendor',
            filename: '/js/vendor.js',
            minChunks: function (module) {
                return module.context && (module.context.indexOf('node_modules') !== -1);
            }
        }),
        new SpritesmithPlugin({
            src: {
                cwd: path.resolve(__dirname, 'public/assets/images/sprites'),
                glob: '*.png'
            },
            target: {
                image: path.resolve(__dirname, 'public/assets/images/sprite.png'),
                css: path.resolve(__dirname, 'public/assets/images/sprite.styl')
            },
            retina: '@2x',
            padding: 2
        })
    ],
    resolve: {
        modules: [
            "node_modules",
            "spritesmith-generated"
        ],
        alias: {
            "eventEmitter/EventEmitter": "wolfy87-eventemitter"
        }
    },
    devtool: 'eval',
    node: {
        fs: 'empty'
    }
};

/**
 * PRODUCTION CONFIG
 */
if (production)
{
    configuration.devtool = 'source-map';

    configuration.plugins.push(
        new webpack.optimize.UglifyJsPlugin({
            options: {
                sourceMap: true,
                compress: {
                    warnings: false,
                    drop_console: true
                },
                output: {
                    comments: false
                }
            }
        })        
    );
}

module.exports = configuration;