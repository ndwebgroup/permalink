module Permalink
  module ActiveRecord
    def self.included(base)
      base.extend(ClassMethods)
      base.extend(Permalink::ActiveRecord::ClassMethods)
      base.cattr_accessor :permalink_options
    end

    module ClassMethods
      # permalink :title
      # permalink :title, to: :custom_permalink_field
      # permalink :title, to: :permalink, to_param: [:id, :permalink]
      # permalink :title, unique: true
      # permalink :title, separator: "_"
      # permalink :title, normalizations: array_of_normalizations
      def permalink(from_column, options = {})
        include InstanceMethods

        options = options.reverse_merge({
          to_param: [:id, :permalink],
          to: :permalink,
          unique: false,
          force: false,
          separator: "-",
          normalizations: Permalink::DEFAULT_NORMALIZATIONS
        })


        self.permalink_options = {} unless self.permalink_options.present?

        set_permalink_options(self.to_s,  {
          from_column_name: from_column,
          to_column_name: options[:to],
          to_param: [options[:to_param]].flatten,
          unique: options[:unique],
          force: options[:force],
          scope: options[:scope],
          separator: options[:separator],
          normalizations: options[:normalizations]
          }
        )

        before_validation :create_permalink
        before_save :create_permalink
      end

      def set_permalink_options(klass, options)
          self.permalink_options = {} unless self.permalink_options
          self.permalink_options[klass] = options
      end

    end

    module InstanceMethods

      def get_permalink_options(klass=nil)
        return self.permalink_options[klass] if klass
        return self.permalink_options
      end


      def to_param
        to_param_option = get_permalink_options(self.class.to_s)[:to_param]

        to_param_option.compact.map {|name|
          respond_to?(name) ? public_send(name).to_s : name.to_s
        }.reject(&:blank?).join(get_permalink_options(self.class.to_s)[:separator])
      end

      private

      def next_available_permalink(permalink)
        unique_permalink = permalink
        scope = build_scope_for_permalink

        if get_permalink_options(self.class.to_s)[:unique]
          suffix = 2

          while scope.where(to_permalink_name => unique_permalink).first
            unique_permalink = [permalink, suffix].join(get_permalink_options(self.class.to_s)[:separator])
            suffix += 1
          end
        end

        unique_permalink
      end

      def build_scope_for_permalink
        search_scope = get_permalink_options(self.class.to_s)[:scope]
        scope = self.class.unscoped
        scope = scope.where(search_scope => public_send(search_scope)) if search_scope
        scope
      end

      def from_permalink_name
        get_permalink_options(self.class.to_s)[:from_column_name]
      end

      def to_permalink_name
        get_permalink_options(self.class.to_s)[:to_column_name]
      end

      def from_permalink_value
        read_attribute(from_permalink_name)
      end

      def to_permalink_value
        read_attribute(to_permalink_name)
      end

      def update_permalink?
        changes[from_permalink_name] &&
        (get_permalink_options(self.class.to_s)[:force] || to_permalink_value.blank?)
      end

      def create_permalink
        write_attribute(
          to_permalink_name,
          next_available_permalink(Permalink.generate(from_permalink_value.to_s, permalink_generator_options))
        ) if update_permalink?
      end

      def permalink_generator_options
        {
          separator: get_permalink_options(self.class.to_s)[:separator],
          normalizations: get_permalink_options(self.class.to_s)[:normalizations]
        }
      end
    end
  end
end
