var AutocompleteInput = React.createClass({

  getDefaultProps: function() {
    return {
      options: [],
      value: '',
      valueLink: null,
      onChange: null,
      autoPreview: true
    };
  },

  getInitialState: function() {
    return {
      isResultsShown: false,
      inputValue: this.props.value,
      value: this.props.value,
      valueLength: 0,
      matchedOptions: this.props.options,
      activeOption: null
    };
  },

  render: function() {
    var className = classNames(
      'react-autocomplete-input',
      this.state.isResultsShown ? 'is-results-shown' : null
    );

    return (
      <span
        className={className}
        onFocus={this.onFocus}
        onBlur={this.onBlur} >
        <input
          ref="input"
          autoComplete="off"
          value={this.state.inputValue}
          className={this.props.className}
          id={this.props.id}
          name={this.props.name}
          type={this.props.type}
          style={this.props.style}
          placeholder={this.props.placeholder}
          onChange={this.handleInputChange}
          onKeyDown={this.handleInputKeyDown} />
        {this.state.isResultsShown ?
          <AutocompleteInputResults
            className="react-autocomplete-input-results dropdown-menu"
            hoverCallBack={this.previewOption}
            selectCallBack={this.selectOption}
            options={this.state.matchedOptions}
            activeOption={this.state.activeOption} />
        : null}
      </span>
    );
  },

  componentDidMount: function() {
    if (this.props.autofocus) {
      this.refs.input.getDOMNode().focus();
    }
  },

  onFocus: function() {
    this.updateResults();
  },

  onBlur: function() {
    this.setState({isResultsShown: false, value: this.state.inputValue});
    this.sendValueChange();
    setTimeout(function() {
      this.sendValueChange();
    }.bind(this), 100);
  },

  componentWillReceiveProps: function(nextProps) {
    setTimeout(function() {
      this.updateResults();
    }.bind(this), 100);
    // updates the input value
    // var value = (nextProps.valueLink && nextProps.valueLink.value) || nextProps.value;
    // if (value ) {
    //   this.setState({value: value, inputValue: value, valueLength: value.length});
    // }
  },

  sendValueChange: function(val) {
    if (typeof val !== 'string') val = this.state.value;
    if (this.props.valueLink) this.props.valueLink.requestChange(val);
    if (this.props.onChange) this.props.onChange(val);
    // console.log(val);
  },

  handleInputChange: function(e) {
    var value = e.target.value;
    this.setState({inputValue: value, value: value, valueLength: value.length});
    this.sendValueChange(value);
    this.updateResults();
    setTimeout(function() {
      this.sendValueChange();
    }.bind(this), 100);
  },

  handleInputKeyDown: function(e) {
    autoPreview = this.props.autoPreview;
    // console.log(e.key);
    // console.log(e.keyCode);
    switch (e.key) {

      case 'ArrowUp':
      case 'ArrowDown':
      case 'Tab':
        if (this.state.isResultsShown) {
          var opts = this.state.matchedOptions;
          var currentOptId = opts.indexOf(this.state.activeOption);

          if (e.key == 'ArrowUp') {
            currentOptId--;
            if (currentOptId < 0) currentOptId = opts.length - 1;
          } else {
            currentOptId++;
            if (currentOptId >= opts.length) currentOptId = 0;
          }

          this.previewOption(opts[currentOptId]);
          e.preventDefault();
        }
        autoPreview = false;
        break;

      case 'Backspace':
        autoPreview = false;
        break;

      case 'Enter':
        if (this.state.activeOption) {
          this.selectOption(this.state.activeOption, true);
          e.preventDefault();
        }
        break;

      case 'ArrowRight':
      case 'ArrowLeft':
        if (this.state.activeOption) {
          this.selectOption(this.state.activeOption);
        }
        break;

      case 'Ctrl':
      case 'Command':
        autoPreview = false;
        break;

      case 'Shift':
      case 'CapsLock':
      case 'Alt':
      case 'Option':
        autoPreview = false;
        break;

      case 'Unidentified':
        if (e.keyCode == 91 || e.keyCode == 93) {
          autoPreview = false;
          this.sleepAutoPreview();
        }
        break;

      default:
        if (this.state.inputValue) this.setState({valueLength: this.state.inputValue.length});
        else this.setState({valueLength: 0});
        // this.updateResults();
        // this.sendValueChange();
        break;
    }

    if (autoPreview) {
      setTimeout(function() {
        this.previewOption(this.state.matchedOptions[0]);
      }.bind(this), 100);
    }
  },

  updateResults: function() {
    inputValue = this.refs.input.getDOMNode().value;
    opts = $.unique(searchArray(inputValue, this.props.options));
    if (opts.length > 0) {
      this.setState({matchedOptions: opts, isResultsShown: true});
      // if (inputValue.length > 0 && !diableAutoPreview)
        // this.previewOption(opts[0]);
    } else {
      this.setState({matchedOptions: opts, isResultsShown: false});
      // this.previewOption(null);
    }
  },

  previewOption: function(opt) {
    this.setState({activeOption: opt});
    if (opt) {
      this.setState({inputValue: opt});
      this.refs.input.getDOMNode().setSelectionRange(this.state.valueLength, 1000);
      setTimeout(function() {
        this.refs.input.getDOMNode().setSelectionRange(this.state.valueLength, 1000);
      }.bind(this), 100);
    }
  },

  selectOption: function(opt, clearSelection) {
    this.setState({activeOption: null});
    if (opt) {
      this.setState({inputValue: opt, value: opt, matchedOptions: []});
      if (clearSelection)
        this.refs.input.getDOMNode().setSelectionRange(1000, 1000);
    }
    this.sendValueChange();
    setTimeout(function() {
      this.sendValueChange();
    }.bind(this), 100);
  },

  sleepAutoPreview: function() {
    if (this.props.autoPreview) {
      this.props.autoPreview = false;
      setTimeout(function() {
        this.props.autoPreview = true;
      }.bind(this), 100);
    }
  }
});


var AutocompleteInputResults = React.createClass({

  getDefaultProps: function() {
    return {
      options: [],
      activeOption: null,
      selectCallBack: function(s) { console.log(s); },
      hoverCallBack: function(s) { console.log(s); }
    };
  },

  render: function() {
    return (
      <ul style={{ display: 'block' }} className={this.props.className} onClick={this.handleSelect} onMouseOver={this.handleMouseOver}>
        {this.props.options.map(function(opt) {
          className = (opt == this.props.activeOption) ? 'active' : '';
          return <li className={className} key={opt} data-value={opt}><a data-value={opt}>{opt}</a></li>;
        }.bind(this))}
      </ul>
    );
  },

  handleSelect: function(e) {
    this.props.selectCallBack(e.target.getAttribute('data-value'));
  },

  handleMouseOver: function(e) {
    this.props.hoverCallBack(e.target.getAttribute('data-value'));
  },
});

function searchArray(term, options) {
  if (!options) {
    return [];
  }

  term = term.replace(/\./mg, '\\\.');

  term = new RegExp('^' + term, 'i');

  var results = [];

  for (var i = 0, len = options.length; i < len; i++) {
    if (term.exec(options[i])) {
      results.push(options[i]);
    }
  }

  return results;
}
