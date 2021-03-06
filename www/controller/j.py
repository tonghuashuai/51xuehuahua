#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import hashlib

from _base import JsonBaseHandler
from misc._route import route
from model.user import User
from model.local_auth import LocalAuth
from model.captcha import Captcha
from model.sms import SMS
from form.local_auth import RegForm


@route('/j/login')
class Login(JsonBaseHandler):
    def post(self):
        user_name = self.get_argument('user_name')
        password = self.get_argument('password')

        form = LocalAuth.Form(**self.arguments)
        if form.validate():
            try:
                local_auth = LocalAuth.exists(user_name)
            except LocalAuth.DoesNotExist:
                result = dict(result=False, user_name="用户不存在")
            else:
                try:
                    local_auth, user = LocalAuth.login(user_name, password)

                    user_dict = dict(
                        id=user.id,
                        name=user.name
                    )
                    self.set_secure_cookie("user", json.dumps(user_dict))
                    result = dict(result=True, msg="")
                except LocalAuth.DoesNotExist:
                    result = dict(result=False, password="密码错误")
        else:
            result = form.errors
            result.update(result=False)

        self.finish(result)


@route('/j/captcha')
class Captcha_(JsonBaseHandler):
    def post(self):
        key, token, img = Captcha.new()

        self.finish(dict(key=key, img=img))


@route('/j/sms_code')
class SMSCode(JsonBaseHandler):
    def post(self):
        form = SMS.Form(**self.arguments)
        if form.validate():
            phone = self.arguments.get('user_name', '')
            try:
                LocalAuth.exists(phone)
            except LocalAuth.DoesNotExist:
                if Captcha.verify(self.arguments.get('key', ''), self.arguments.get('token', '')):
                    SMS.new(phone)
                    result = dict(result=True)
                else:
                    result = dict(result=False, token="图片验证码错误")
            else:
                result = dict(result=False, user_name="手机号码已注册")
        else:
            result = form.errors
            result.update(result=False)
        self.finish(result)


@route('/j/reg')
class Reg(JsonBaseHandler):
    def post(self):
        form = RegForm(**self.arguments)
        if form.validate():
            phone = self.arguments.get('user_name')

            # 验证手机验证码
            if SMS.verify(phone, self.arguments.get('sms_code', '')):
                try:
                    LocalAuth.exists(phone)
                except LocalAuth.DoesNotExist:
                    user = User(phone=phone)
                    user.save()

                    LocalAuth.create(user_id=user.id, user_name=phone,
                                     password=hashlib.md5(self.arguments.get('password')).hexdigest())

                    result = dict(result=True)
                else:
                    result = dict(result=False, user_name="手机号码已注册")
            else:
                result = dict(result=False, sms_code="验证码错误")

        else:
            result = form.errors
            result.update(result=False)

        self.finish(result)
