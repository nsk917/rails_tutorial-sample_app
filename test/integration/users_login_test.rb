require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    # ログイン用のパスを開く
    get login_path
    # 新しいセッションのフォームが正しく表示されたことを確認する
    assert_template 'sessions/new'
    # わざと無効なparamsハッシュを使ってセッション用パスにPOSTする
    post login_path, params: { session: {email: "", password: "" } }
    # 新しいセッションのフォームが再度表示され、フラッシュメッセージが追加されることを確認する
    assert_template 'sessions/new'
    assert_not flash.empty?
    # 別のページ (Homeページなど) にいったん移動する
    get root_path
    # 移動先のページでフラッシュメッセージが表示されていないことを確認する
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    # ログイン用のパスを開く
    get login_path
    # セッション用パスに有効な情報をpostする
    post login_path, params: { session: { email: @user.email, password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user # リダイレクト先が正しいかどうか
    follow_redirect! # リダイレクト先に実際に移動する
    assert_template 'users/show' #

    # ログイン用リンクが表示されなくなったことを確認する
    assert_select "a[href=?]", login_path, count: 0
    # ログアウト用リンクが表示されていることを確認する
    assert_select "a[href=?]", logout_path
    # プロフィール用リンクが表示されていることを確認する
    assert_select "a[href=?]", user_path(@user)

    delete logout_path # /logout に DELETEのリクエストを送っている
    assert_not is_logged_in?
    assert_redirected_to root_url
    # 2番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remmbering" do
    log_in_as(@user, remember_me: '1')
    assert_equal cookies['remember_token'], assigns(:user).remember_token
  end

  test "login without remembering" do
    # クッキーを保存してログイン
    log_in_as(@user, remember_me: '1')
    delete logout_path
    # クッキーを削除してログイン
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
end
