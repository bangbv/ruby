# frozen_string_literal: true

require 'open-uri'
require 'json'
require 'csv'

# class for handling multi-threads
class MyThreadPools
  attr_accessor :bread_list, :mutex

  def initialize(bread_list, mutex)
    @mutex = mutex.new
    @bread_list = bread_list
  end

  def my_download
    bread_name = ''
    while @bread_list.length.positive?
      # puts "bread list length:#{@bread_list.length}"
      @mutex.synchronize do
        @bread_list.length.positive? ? bread_name = @bread_list.shift : break
      end
      read_write(bread_name)
    end
  end

  def read_write(bread_name)
    headers = %w[BreedName LinkToTheImage]
    result = []
    open("https://dog.ceo/api/breed/#{bread_name}/images", 'rb') do |read_file|
      result = JSON.parse(read_file.read)['message']
    end
    CSV.open("./data/#{bread_name}.csv", 'a+') do |saved_file|
      puts bread_name
      saved_file << headers
      result.each { |line| saved_file << %W[#{bread_name} #{line}] }
    end
  end

  def main
    arr = []
    5.times do |i|
      arr[i] = Thread.new do
        my_download
      end
    end
    # puts "Started At #{Time.now}\n"
    arr.each(&:join)
    # puts "End at #{Time.now}\n"
  end
end

mutex = Mutex
bread_list = []
open('https://dog.ceo/api/breeds/list') do |json|
  bread_list = JSON.parse(json.read)['message']
  open('./data/updated_at.json', 'w') do |update_at|
    bread_list.each { |file_name| update_at.write("#{file_name}.csv\n") }
  end
end
mpt = MyThreadPools.new(bread_list, mutex)
mpt.main
