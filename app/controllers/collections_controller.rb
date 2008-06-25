class CollectionsController < ApplicationController

  before_filter :verify_client

  verify :method => :post, 
         :only => :create, 
         :render => { :status => :method_not_allowed },
         :add_headers => {'Allow' => 'POST'}

  verify :method => :delete,
         :only => [ :delete ],
         :render => { :status => :method_not_allowed },
         :add_headers => {'Allow' => 'DELETE'}

  verify :method => :put,
         :only => [ :update ],
         :render => { :status => :method_not_allowed },
         :add_headers => {'Allow' => 'PUT'}

  def index
    @collections = Collection.find(:all, :conditions => { :client_id => session["client"] })
  end

  def show

    begin
      @collection = Collection.find(params['id'])
    rescue ActiveRecord::RecordNotFound
      render :status => :not_found and return
    end

    if @collection.client != session_client or ! @collection.read?(session_user, session_client)
      @collection = nil
      render :status => :forbidden
    end
  end

  def create
    @collection = Collection.new

    if params['owner'] and params['owner'] = session['user']
      @collection.owner = Person.find(session['user'])
    end

    @collection.client = Client.find(session['client'])
    @collection.save
  end

  def update
    @collection = Collection.find(params['id'])
    @collection.update_attributes(params[:collection])
  end

  def delete
    @collection = Collection.find(params['id'])
    if ! @collection.delete?(session_user, session_client)
      render :status => :forbidden and return
    end
    @collection.destroy
  end

  private
  def verify_client
    if session_client == nil or params["app_id"].to_s != session_client.id.to_s
      render :status => :forbidden and return
    end
  end

end
