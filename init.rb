require 'rubygems'
require 'sinatra'
require 'memcache'

CACHE = MemCache.new 'localhost:11211', :namespace => 'fib'
CACHE.set(0, 0)
CACHE.set(1, 1)

get '/' do
  haml :index
end

get %r{/api/v1/fibonacci/([\d]+)} do
  n = params[:captures].first.to_i
  fib(n).to_s
end 

def fib(n)
  fib_n = CACHE.get(n)
  unless fib_n
    return n if (0..1).include? n

    n_1 = CACHE.get(n - 1)
    unless n_1
      n_1 = fib(n - 1)
      CACHE.set(n - 1, n_1)
    end

    n_2 = CACHE.get(n - 2)
    unless n_2 
      n_2 = fib(n - 2)
      CACHE.set(n - 2, n_2)
    end

    fib_n = n_1 + n_2
    CACHE.set(n, fib_n)
  end

  fib_n
end

__END__

@@ layout
%html
  %head
    %title iFib
  %body
    = yield

@@ index

%h1 iFib
%p
  iFib provides a RESTful API for calculating the fibonacci sequencing

%h2 Usage

%p
  The base URI is http://ifib/api/v1

%h3 fibonacci

%blockquote
  http://ifib/api/v1/fibonacci/:number:

%p
  Returns the fibonacci number of :number:

%p Example:
%blockquote
  %pre $ curl http://localhost:4567/api/v1/fibonacci/119
