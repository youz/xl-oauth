# xl-oauth

OAuth 1.0 �N���C�A���g���C�u���� for xyzzy


## Install
- NetInstaller�����C���X�g�[��
  ���L��URL�̃p�b�P�[�W���X�g��o�^���A�p�b�P�[�W`*scrap*`���C���X�g�[�����ĉ������B
  http://youz.github.com/xyzzy/package.l

- �蓮�C���X�g�[��
  oauth.l ��`*load-path*`�ɔz�u���Ă��������B

���ˑ����C�u����[xml-http-request](http://miyamuko.s56.xrea.com/xyzzy/xml-http-request/intro.htm)��ʓr�C���X�g�[�����Ă����K�v������܂��B


## Usage

- oauth:get-access-token
  (consumer-key consumer-secret request-token-url authorize-url access-token-url)
    => access-token, access-token-secret

  �ȉ��̈�A�̔F�؏��������s���A�擾�����A�N�Z�X�g�[�N��(oauth_token, oauth_token_secret)�𑽒l�ŕԂ��܂��B
  1. ���N�G�X�g�g�[�N���̗v��
  2. �F�ؗp�y�[�W�\�� (�V�X�e���W����WEB�u���E�U���N�����ĕ\�����܂�)
  3. PIN (oauth_verifier) ����
  4. �A�N�Z�X�g�[�N���擾

  ����
  - cosumer-key - �T�[�r�X�v���o�C�_��蔭�s���ꂽConsumer Key
  - consumer-secret - �T�[�r�X�v���o�C�_��蔭�s���ꂽConsumer Secret
  - request-token-url - ���N�G�X�g�g�[�N�����s�pURL
  - authorize-url - �T�[�r�X�v���o�C�_�̔F�ؗpURL
  - access-token-url - �A�N�Z�X�g�[�N�����s�pURL

  twitter���A�N�Z�X�g�[�N�����擾���A�t�@�C���ɕۑ������

        (multiple-value-bind (token token-secret)
            (get-access-token *my-app-key* *my-app-secret*
                              "http://api.twitter.com/oauth/request_token"
                              "http://api.twitter.com/oauth/authorize"
                              "http://api.twitter.com/oauth/access_token")
          (with-open-file (str *token-file* :direction :output)
            (format str "~A~%~A" token token-secret)))

- oauth:auth-header
  (credential method apiurl params)
  => header-string

  �T�[�r�X�v���o�C�_��API�𗘗p����ۂɕK�v��OAuth�F�؃w�b�_�𐶐����܂��B

  ����
  - credential
    �R���V���[�}�L�[, �R���V���[�}�V�[�N���b�g, �A�N�Z�X�g�[�N��, �A�N�Z�X�g�[�N����plist�B
    �L�[�V���{���͂��ꂼ�� :consumer-key, :consumer-secret, :token, :token-secret �ł��B
  - method - HTTP���\�b�h���V���{����������Ŏw�肵�܂��B
  - apiurl - API��URL
  - params - API�ɓn���p�����[�^��plist�Ŏw�肵�܂��B

  twitter��[help/test API](https://dev.twitter.com/docs/api/1/get/help/test)�Ƀ��N�G�X�g�𓊂����

        (let* ((url "http://api.twitter.com/1/help/test.json")
               (cred (list :consumer-key *my-app-key*
                           :consumer-secret *my-app--secret*
                           :token *token*
                           :token-secret *token-secret*))
               (auth (oauth:auth-header cred 'get url nil)))
          (xhr:xhr-get url :headers `(:Authorization ,auth)
                       :key #'xhr:xhr-response-text))


## Author
Yousuke Ushiki (<citrus.yubeshi@gmail.com>)

[@Yubeshi](http://twitter.com/Yubeshi/)

## Copyright
MIT License ��K�p���Ă��܂��B

