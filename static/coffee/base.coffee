$.extend({
    # app: angular.module('app', ['ngRoute'])

    tip: (msg)->
        $('#msg').attr('class', 'alert alert-info')
        $('#msg').css('display', 'block')
        $('#msg').html(msg)

    alert: (msg)->
        $('#msg').attr('class', 'alert alert-danger')
        $('#msg').css('display', 'block')
        $('#msg').html(msg)

    _ajax: (option)->
        target = option.target

        $.ajax({
            method: option.method,
            url: option.url,
            data: option.data,
            type: option.type or 'POST'
            success: (r)->
                $('.err').each ->
                    $(this).removeClass('err')

                if r.result
                    option.success(r)
                else
                    for k, v of r
                        p = $("##{k}").parents("div.form-group")
                        p.addClass('err')

                        msg = v
                        if Array.isArray(v)
                            msg = v[0]
                            if Array.isArray(v[0])
                                msg = v[0][0]
                        p.children('.error-msg').html(msg)

                    if option.fail
                        option.fail()

                if target
                    target.attr('disabled', '')
                    target.removeClass('disabled')

            fail: ->
                if option.fail
                    option.fail()

                if target
                    target.attr('disabled', '')
                    target.removeClass('disabled')
        })

	upload: (option)->
		browse_button = option.browse_button
		uploader = Qiniu.uploader({
			runtimes: 'html5,flash,html4',    # 上传模式,依次退化
			browse_button: browse_button,       # 上传选择的点选按钮，**必需**
			uptoken_url: '/j/qiniu_token',            # Ajax请求upToken的Url，**强烈建议设置**（服务端提供）
			domain: 'http://oc06pejhd.bkt.clouddn.com/',   # bucket 域名，下载资源时用到，**必需**
			# container: 'container',           # 上传区域DOM ID，默认是browser_button的父元素，
			max_file_size: '100mb',           # 最大文件体积限制
			# flash_swf_url: 'js/plupload/Moxie.swf',  # 引入flash,相对路径
			max_retries: 3,                   # 上传失败最大重试次数
			dragdrop: true,                   # 开启可拖曳上传
			save_key: true,                   # 开启可拖曳上传
			# drop_element: 'container',        # 拖曳上传区域元素的ID，拖曳文件或文件夹后可触发上传
			chunk_size: '4mb',                # 分块上传时，每片的体积
			auto_start: true,                 # 选择文件后自动上传，若关闭需要自己绑定事件触发上传
			filters: {
				mime_types : [
					option.mime_types or { title : "图片文件", extensions : "jpg,gif,png,bmp,jpeg" }
				]
			}
			init: {
				'FilesAdded': (up, files) ->
					plupload.each(files, (file)->
						# 文件添加进队列后,处理相关的事情
					)

				'BeforeUpload': (up, file)->
					# 每个文件上传前,处理相关的事情
					option.BeforeUpload(up, file)

				'UploadProgress': (up, file)->
					option.UploadProgress(up, file)
					   # 每个文件上传时,处理相关的事情

				'FileUploaded': (up, file, info) ->
					domain = up.getOption('domain')
					res = $.parseJSON(info)
					url = domain + res.key  # 获取上传成功后的文件的Url
					option.FileUploaded(up, file, res, url)

				'Error': (up, err, errTip)->
					# 上传出错时,处理相关的事情

				'UploadComplete': ->
					# 队列文件处理完毕后,处理相关的事情
            }
		})
})
