module Spira
 module Resource

   # This module contains all class methods available to a Spira::Resource class
   #
   #
    module ClassMethods
      def repository=(repo)
        @repository = repo
      end

      def repository
        case
          when !@repository.nil?
            @repository
          when !@repository_name.nil?
            @repository = Spira.repository(@repository_name)
            if @repository.nil?
              raise RuntimeError, "#{self} is configured to use #{@repository_name} as a repository, but was unable to find it."
            end
          else
            @repository = Spira.repository(:default)
            if @repository.nil? 
              raise RuntimeError, "#{self} has no configured repository and was unable to find a default repository."
            end
        end
        @repository
      end

      def find(identifier)
        uri = case identifier
          when RDF::URI
            identifier
          when String
            raise ArgumentError, "Cannot find #{self} by String without base_uri; RDF::URI required" if self.base_uri.nil?
            RDF::URI.parse(self.base_uri.to_s + "/" + identifier)
          else
            raise ArgumentError, "Cannot instantiate #{self} from #{identifier}, expected RDF::URI or String"
        end
        statements = self.repository.query(:subject => uri)
        if statements.empty?
          nil
        else
          self.new(identifier, :statements => statements) 
        end
      end
 
      def count
        raise TypeError, "Cannot count a #{self} without a reference type URI." if @type.nil?
        result = repository.query(:predicate => RDF.type, :object => @type)
        result.count
      end

      def create(name, attributes = {})
        # TODO: validate attributes
        if !@type.nil?
          if attributes[:type]
            raise TypeError, "Cannot assign type to new instance of #{self}; type must be #{@type}"
          end
          attributes[:type] = @type
        end
        resource = self.new(name, attributes)
      end
  
    end
  end
end