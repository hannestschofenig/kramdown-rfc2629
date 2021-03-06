module KramdownRFC

  class ParameterSet
    include Kramdown::Utils::Html

    attr_reader :f
    def initialize(y)
      raise "*** invalid parameter set #{y.inspect}" unless Hash === y
      @f = y
    end
    def [](pn)
      @f.delete(pn.to_s)
    end
    def has(pn)
      @f[pn.to_s]
    end
    def escattr(str)
      escape_html(str.to_s, :attribute)
    end
    def van(pn)                   # pn is a parameter name, possibly with an =alias
      an, pn = pn.to_s.split("=")
      pn ||= an
      [self[pn] || self[an], an]
    end
    def attr(pn)
      val, an = van(pn)
      %{#{an}="#{escattr(val)}"}    if val
    end
    def attrs(*pns)
      pns.map{ |pn| attr(pn) }.compact.join(" ")
    end
    def ele(pn, attr=nil, defcontent=nil, markdown=false)
      val, an = van(pn)
      val ||= defcontent
      Array(val).map do |val1|
        v = val1.to_s.strip
        if markdown             # Uuh.  Heavy coupling.
          doc = Kramdown::Document.new(v, $global_markdown_options)
          $stderr.puts doc.warnings.to_yaml unless doc.warnings.empty?
          contents = doc.to_rfc2629[3..-6] # skip <t>...</t>\n
        else
          contents = escape_html(v)
        end
        %{<#{[an, *Array(attr).map(&:to_s)].join(" ").strip}>#{contents}</#{an}>}
      end.join(" ")
    end
    def arr(an, converthash=true, must_have_one=false, &block)
      arr = self[an] || []
      arr = [arr] if Hash === arr && converthash
      arr << { } if must_have_one && arr.empty?
      Array(arr).each(&block)
    end
    def rest
      @f
    end
    def warn_if_leftovers
      if !@f.empty?
        warn "*** attributes left #{@f.inspect}!"
      end
    end
  end

  
end
