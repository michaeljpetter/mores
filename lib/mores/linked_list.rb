module Mores

  class LinkedList
    include Enumerable

    NOMATCH = BasicObject.new
    private_constant :NOMATCH

    attr_reader :length, :head, :tail
    alias :size :length

    def initialize
      @length = 0
    end

    def empty?
      !@head
    end

    def count(*args)
      return @length if args.empty? && !block_given?
      super
    end

    def each
      return to_enum(__callee__) { @length } unless block_given?
      each_node { |n| yield n.value }
    end

    def reverse_each
      return to_enum(__callee__) { @length } unless block_given?
      reverse_each_node { |n| yield n.value }
    end

    def each_node
      return to_enum(__callee__) { @length } unless block_given?
      node = @head
      until node.nil?
        node = (cur = node).next
        yield cur
      end
      self
    end

    def reverse_each_node
      return to_enum(__callee__) { @length } unless block_given?
      node = @tail
      until node.nil?
        node = (cur = node).prev
        yield cur
      end
      self
    end

    def <<(value)
      insert nil, @head, value
    end

    def >>(value)
      insert @tail, nil, value
    end

    def clear
      each_node { |n| n.send :clear }
      @head = @tail = nil
      @length = 0
      self
    end

    def delete(value)
      last = each_node.reduce(NOMATCH) { |v, n| n.value == value ? n.delete : v }
      return last unless last == NOMATCH
      yield value if block_given?
    end

    def delete_if
      return to_enum(__callee__) { @length } unless block_given?
      each_node { |n| n.delete if yield n.value }
    end

    private

    def insert(before, after, value)
      node = Node.new(self, value)

      unless before
        @head = node
      else
        before.send :next=, node
        node.send :prev=, before
      end

      unless after
        @tail = node
      else
        after.send :prev=, node
        node.send :next=, after
      end

      @length += 1
      self
    end

    def remove(node)
      before = node.prev
      after = node.next

      unless before
        @head = after
      else
        before.send :next=, after
      end

      unless after
        @tail = before
      else
        after.send :prev=, before
      end

      @length -= 1
      self
    end

    class Node
      attr_reader :list, :prev, :next
      attr_accessor :value

      def initialize(list, value)
        @list = list
        @value = value
      end

      def <(value)
        list.send :insert, @prev, self, value
        self
      end

      def >(value)
        list.send :insert, self, @next, value
        self
      end

      def delete
        list.send :remove, self
        clear
        value
      end

      private

      def prev=(node)
        @prev = node
      end

      def next=(node)
        @next = node
      end

      def clear
        @list = @prev = @next = nil
      end
    end
  end

end
