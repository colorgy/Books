(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.AutosizeInput = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function (global){
'use strict';

var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

var React = (typeof window !== "undefined" ? window.React : typeof global !== "undefined" ? global.React : null);

var sizerStyle = { position: 'absolute', visibility: 'hidden', height: 0, width: 0, overflow: 'scroll', whiteSpace: 'nowrap' };

var AutosizeInput = React.createClass({

  displayName: 'AutosizeInput',

  propTypes: {
    value: React.PropTypes.any, // field value
    defaultValue: React.PropTypes.any, // default field value
    onChange: React.PropTypes.func, // onChange handler: function(newValue) {}
    style: React.PropTypes.object, // css styles for the outer element
    className: React.PropTypes.string, // className for the outer element
    minWidth: React.PropTypes.oneOfType([// minimum width for input element
    React.PropTypes.number, React.PropTypes.string]),
    inputStyle: React.PropTypes.object, // css styles for the input element
    inputClassName: React.PropTypes.string // className for the input element
  },

  getDefaultProps: function getDefaultProps() {
    return {
      minWidth: 1
    };
  },

  getInitialState: function getInitialState() {
    return {
      inputWidth: this.props.minWidth
    };
  },

  componentDidMount: function componentDidMount() {
    this.copyInputStyles();
    this.updateInputWidth();
  },

  componentDidUpdate: function componentDidUpdate() {
    this.updateInputWidth();
  },

  copyInputStyles: function copyInputStyles() {
    if (!this.isMounted() || !window.getComputedStyle) {
      return;
    }
    var inputStyle = window.getComputedStyle(this.refs.input.getDOMNode());
    var widthNode = this.refs.sizer.getDOMNode();
    widthNode.style.fontSize = inputStyle.fontSize;
    widthNode.style.fontFamily = inputStyle.fontFamily;
    if (this.props.placeholder) {
      var placeholderNode = this.refs.placeholderSizer.getDOMNode();
      placeholderNode.style.fontSize = inputStyle.fontSize;
      placeholderNode.style.fontFamily = inputStyle.fontFamily;
    }
  },

  updateInputWidth: function updateInputWidth() {
    if (!this.isMounted() || typeof this.refs.sizer.getDOMNode().scrollWidth === 'undefined') {
      return;
    }
    var newInputWidth;
    if (this.props.placeholder) {
      newInputWidth = Math.max(this.refs.sizer.getDOMNode().scrollWidth, this.refs.placeholderSizer.getDOMNode().scrollWidth) + 2;
    } else {
      newInputWidth = this.refs.sizer.getDOMNode().scrollWidth + 2;
    }
    if (newInputWidth < this.props.minWidth) {
      newInputWidth = this.props.minWidth;
    }
    if (newInputWidth !== this.state.inputWidth) {
      this.setState({
        inputWidth: newInputWidth
      });
    }
  },

  getInput: function getInput() {
    return this.refs.input;
  },

  focus: function focus() {
    this.refs.input.getDOMNode().focus();
  },

  select: function select() {
    this.refs.input.getDOMNode().select();
  },

  render: function render() {

    var nbspValue = (this.props.value || '').replace(/ /g, '&nbsp;');

    var wrapperStyle = this.props.style || {};
    wrapperStyle.display = 'inline-block';

    var inputStyle = this.props.inputStyle || {};
    inputStyle.width = this.state.inputWidth;

    var placeholder = this.props.placeholder ? React.createElement(
      'div',
      { ref: 'placeholderSizer', style: sizerStyle },
      this.props.placeholder
    ) : null;

    return React.createElement(
      'div',
      { className: this.props.className, style: wrapperStyle },
      React.createElement('input', _extends({}, this.props, { ref: 'input', className: this.props.inputClassName, style: inputStyle })),
      React.createElement('div', { ref: 'sizer', style: sizerStyle, dangerouslySetInnerHTML: { __html: nbspValue } }),
      placeholder
    );
  }

});

module.exports = AutosizeInput;

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{}]},{},[1])(1)
});
