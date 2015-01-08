class Entanglement

  attr_accessor :calls

  def initialize
    @calls = []
  end

  def trace
    stack = [{object_id: self.object_id, object_class: self.class}]

    trace = TracePoint.new(:call, :return) do |tp|
      case tp.event
        when :call
          caller = stack.last
          receiver = {object_id: tp.self.object_id, object_class: tp.self.class}
          stack.push receiver
          @calls.push({caller: caller, receiver: receiver})
        when :return
          stack.pop
        else
          raise 'BOOM!'
      end
    end

    trace.enable

    yield
  ensure
    trace.disable
  end

end
