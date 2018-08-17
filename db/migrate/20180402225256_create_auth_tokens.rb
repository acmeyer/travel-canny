class CreateAuthTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :auth_tokens do |t|
      t.string :token, index: true
      t.belongs_to :user, index: true
      t.datetime :last_used_at
      t.datetime :expires_at
      t.inet :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
