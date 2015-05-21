require_relative '../lib/router'
require_relative '../lib/controller_base'

class CatsController < Monastery::ControllerBase
end

class Cat
  def id
    (1..10).to_a.sample
  end
end

def cat_object
  $cat_object ||= Cat.new
end

def router
  $router ||= Monastery::Router.new
end

router.draw do
  resources :cats
end
