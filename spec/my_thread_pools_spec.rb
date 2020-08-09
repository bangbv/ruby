# frozen_string_literal: true

require 'rspec'

describe 'MyThreadPools' do
  context "given 'african'" do
    mutex = Mutex
    bread_list = ['african']
    mpt = MyThreadPools.new(bread_list, mutex)
    mpt.main
    expect mpt.main.equal('african')
  end
end
