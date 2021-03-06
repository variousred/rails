module ActiveRecord
  module ConnectionAdapters
    module PostgreSQL
      module Cast # :nodoc:
        def point_to_string(point) # :nodoc:
          "(#{number_for_point(point[0])},#{number_for_point(point[1])})"
        end

        def number_for_point(number)
          number.to_s.gsub(/\.0$/, '')
        end

        def hstore_to_string(object, array_member = false) # :nodoc:
          if Hash === object
            string = object.map { |k, v| "#{escape_hstore(k)}=>#{escape_hstore(v)}" }.join(', ')
            string = escape_hstore(string) if array_member
            string
          else
            object
          end
        end

        def string_to_hstore(string) # :nodoc:
          if string.nil?
            nil
          elsif String === string
            Hash[string.scan(HstorePair).map { |k, v|
              v = v.upcase == 'NULL' ? nil : v.gsub(/\A"(.*)"\Z/m,'\1').gsub(/\\(.)/, '\1')
              k = k.gsub(/\A"(.*)"\Z/m,'\1').gsub(/\\(.)/, '\1')
              [k, v]
            }]
          else
            string
          end
        end

        def json_to_string(object) # :nodoc:
          if Hash === object || Array === object
            ActiveSupport::JSON.encode(object)
          else
            object
          end
        end

        def range_to_string(object) # :nodoc:
          from = object.begin.respond_to?(:infinite?) && object.begin.infinite? ? '' : object.begin
          to   = object.end.respond_to?(:infinite?) && object.end.infinite? ? '' : object.end
          "[#{from},#{to}#{object.exclude_end? ? ')' : ']'}"
        end

        def string_to_json(string) # :nodoc:
          if String === string
            ActiveSupport::JSON.decode(string)
          else
            string
          end
        end

        private

          HstorePair = begin
            quoted_string = /"[^"\\]*(?:\\.[^"\\]*)*"/
            unquoted_string = /(?:\\.|[^\s,])[^\s=,\\]*(?:\\.[^\s=,\\]*|=[^,>])*/
            /(#{quoted_string}|#{unquoted_string})\s*=>\s*(#{quoted_string}|#{unquoted_string})/
          end

          def escape_hstore(value)
            if value.nil?
              'NULL'
            else
              if value == ""
                '""'
              else
                '"%s"' % value.to_s.gsub(/(["\\])/, '\\\\\1')
              end
            end
          end
      end
    end
  end
end
