class PaymentsController < ApplicationController

  skip_after_action :verify_authorized
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  before_action :set_order, except: :confirmation

  # def new
  #   @order= Order.find(params[:order_id])
  # end

  def create

    customer = Stripe::Customer.create(
    source: params[:stripeToken],
    email:  params[:stripeEmail]
  )

  charge = Stripe::Charge.create(
    customer:     customer.id,   # You should store this customer id and re-use it.
    amount:       @order.amount_cents,
    description:  "Payment for order #{@order.id}",
    currency:     @order.amount.currency
  )

  @order.update!(payment: charge.to_json, status: 'paid')
  authorize @order
  redirect_to confirmation_path(@order)

  rescue Stripe::CardError => e
    flash[:alert] = e.message
    redirect_to orders_path
  end

  def confirmation
    @order = Order.find(params[:order_id])
    # user = User.first
    # UserMailer.welcome(user).deliver_now

  end


private

  def set_order
    @order = Order.where(status: 'new').find(params[:order_id])
    #authorize @order
  end
end
