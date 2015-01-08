require 'entanglement'

describe Entanglement do

  class Doer
    def initialize(receiver = nil)
      @receiver = receiver
    end

    def do_stuff
      @receiver.do_stuff if @receiver
    end
  end

  class Boomer
    def do_stuff
      raise 'BOOM!'
    end
  end

  it 'Tracks messages between 2 objects' do
    a = Doer.new
    b = Doer.new a

    entanglement = Entanglement.new

    entanglement.trace do
      b.do_stuff
    end

    expect(entanglement.calls).to eq([{
                                          caller: {object_id: entanglement.object_id, object_class: Entanglement},
                                          receiver: {object_id: b.object_id, object_class: Doer}
                                      },
                                      {
                                          caller: {object_id: b.object_id, object_class: Doer},
                                          receiver: {object_id: a.object_id, object_class: Doer}
                                      }
                                     ])
  end

  it 'handles exceptions' do
    a = Boomer.new
    b = Doer.new a

    entanglement = Entanglement.new

    begin
      entanglement.trace do
        b.do_stuff
      end
    rescue
      # puts 'rescuing!'
    end


    expect(entanglement.calls).to eq([{
                                          caller: {object_id: entanglement.object_id, object_class: Entanglement},
                                          receiver: {object_id: b.object_id, object_class: Doer}
                                      },
                                      {
                                          caller: {object_id: b.object_id, object_class: Doer},
                                          receiver: {object_id: a.object_id, object_class: Boomer}
                                      }
                                     ])

  end
end
