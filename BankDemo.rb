require 'securerandom'

# Define the Bank class
class Bank
  attr_accessor :accounts

  def initialize
    @accounts = {}
  end

  def start
    loop do
      puts "Welcome to the Bank System"
      puts "1. Signup"
      puts "2. Login"
      puts "3. Exit"
      option = get_valid_input("Choose an option: ", method(:valid_menu_option?), "Invalid option. Please try again.", :to_i)
      next unless option

      case option
      when 1
        signup
      when 2
        login
      when 3
        puts "Thank you for using the Bank System."
        break
      else
        puts "Invalid option. Please try again."
      end
    end
  end

  private

  def signup
    name = get_valid_input("Enter your name: ", method(:valid_name?), "Invalid name! Name should only contain alphabetic characters.")
    return unless name

    mobile = get_valid_input("Enter your mobile number: ", method(:valid_mobile?), "Invalid mobile number! It should be 10 digits.")
    return unless mobile

    age = get_valid_input("Enter your age: ", method(:valid_age?), "Invalid age! You must be above 18 to create an account.", :to_i)
    return unless age

    nominee = get_valid_input("Enter nominee name: ", method(:valid_name?), "Invalid nominee name! Name should only contain alphabetic characters.")
    return unless nominee

    password = get_valid_input("Enter your password: ", method(:valid_password?), "Invalid password! Password must be at least 6 characters.")
    return unless password

    account_number = generate_account_number
    @accounts[account_number] = {
      name: name, 
      mobile: mobile, 
      age: age, 
      nominee: nominee, 
      password: password, 
      balance: 0.0
    }

    puts "Signup successful! Your account number is: #{account_number}"
  end

  def login
    account_number = get_valid_input("Enter your account number: ", method(:valid_account_number?), "Invalid account number.")
    return unless account_number

    password = get_valid_input("Enter your password: ", method(:valid_password?), "Invalid password.")
    return unless password

    if @accounts.key?(account_number) && @accounts[account_number][:password] == password
      puts "Login successful!"
      account_dashboard(account_number)
    else
      puts "Invalid account number or password."
    end
  end

  def account_dashboard(account_number)
    loop do
      puts "\nAccount Dashboard for #{@accounts[account_number][:name]}"
      puts "Account Balance: $#{'%.2f' % @accounts[account_number][:balance]}"
      puts "1. Deposit"
      puts "2. Withdraw"
      puts "3. Transaction"
      puts "4. Logout"
      option = get_valid_input("Choose an option: ", method(:valid_menu_option?), "Invalid option. Please try again.", :to_i)
      next unless option

      case option
      when 1
        deposit(account_number)
      when 2
        withdraw(account_number)
      when 3
        transaction(account_number)
      when 4
        puts "Logged out successfully."
        break
      else
        puts "Invalid option. Please try again."
      end
    end
  end

  def deposit(account_number)
    amount = get_valid_input("Enter amount to deposit: $", method(:valid_amount?), "Invalid amount. Please enter a valid positive number.", :to_f)
    return unless amount

    @accounts[account_number][:balance] += amount
    puts "Successfully deposited $#{'%.2f' % amount}."
  end

  def withdraw(account_number)
    return unless verify_password(account_number)

    amount = get_valid_input("Enter amount to withdraw: $", method(:valid_amount?), "Invalid amount. Please enter a valid positive number.", :to_f)
    return unless amount

    if amount > @accounts[account_number][:balance]
      puts "Insufficient balance."
      return
    end

    @accounts[account_number][:balance] -= amount
    puts "Successfully withdrew $#{'%.2f' % amount}."
  end

  def transaction(account_number)
    return unless verify_password(account_number)

    target_account = get_valid_input("Enter the account number to transfer to: ", method(:valid_account_number?), "Invalid account number.")
    return unless target_account

    if !@accounts.key?(target_account)
      puts "Target account does not exist."
      return
    end

    amount = get_valid_input("Enter the amount to transfer: $", method(:valid_amount?), "Invalid amount. Please enter a valid positive number.", :to_f)
    return unless amount

    if amount > @accounts[account_number][:balance]
      puts "Insufficient balance."
      return
    end

    @accounts[account_number][:balance] -= amount
    @accounts[target_account][:balance] += amount
    puts "Successfully transferred $#{'%.2f' % amount} to account #{target_account}."
  end

  # Verifies password with 3 attempts
  def verify_password(account_number)
    3.times do
      password = get_valid_input("Enter your password: ", method(:valid_password?), "Invalid password.")
      return true if @accounts[account_number][:password] == password

      puts "Incorrect password. Please try again."
    end
    puts "Too many incorrect password attempts. Action aborted."
    false
  end

  # Helper methods for input validation
  def generate_account_number
    "1234" + SecureRandom.random_number(10**12).to_s.rjust(12, '0')
  end

  # General method to get valid input with 3 attempts
  def get_valid_input(prompt, validation_method, error_message, conversion_method = :to_s)
    attempts = 0
    while attempts < 3
      print prompt
      input = gets.chomp.send(conversion_method)
      if validation_method.call(input)
        return input
      else
        puts error_message
        attempts += 1
        puts "You have #{3 - attempts} attempts left."
      end
    end
    puts "Too many invalid attempts."
    return nil
  end

  # Validation methods
  def valid_name?(name)
    name.match?(/^[A-Za-z\s]+$/) # Only allows alphabetic characters and spaces
  end

  def valid_mobile?(mobile)
    mobile.match?(/^\d{10}$/) # Mobile number must be 10 digits
  end

  def valid_age?(age)
    age > 18 # Age must be greater than 18
  end

  def valid_password?(password)
    password.length >= 6 # Password must be at least 6 characters long
  end

  def valid_account_number?(account_number)
    account_number.match?(/^\d{16}$/) # Account number must be exactly 16 digits
  end

  def valid_amount?(amount)
    amount > 0 # Amount must be positive
  end

  def valid_menu_option?(option)
    [1, 2, 3, 4].include?(option) # Valid options for menus
  end
end

# Start the Bank system
bank = Bank.new
bank.start
