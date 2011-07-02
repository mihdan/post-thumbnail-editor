###
  POST-THUMBNAIL-EDITOR Script for Wordpress

  Hooks into the Wordpress Media Library
###
do (pte) ->

	pte.admin = ->
		timeout = 300
		thickbox = """&TB_iframe=true&height=#{ pte_tb_height }&width=#{ pte_tb_width }"""
		image_id = null
		pte_url = ->
			id = image_id || $("#attachment-id").val()
			"#{ ajaxurl }?action=pte_ajax&pte-action=launch&id=#{ id }#{ thickbox }"


		fixThickbox = (parent) ->
			p$ = parent.jQuery
			if p$ == null then return
			log "Got thickbox"
			width = pte_tb_width + 40
			height = pte_tb_height
			thickbox = p$("#TB_window").css
				'margin-left': 0 - (width / 2)
				'width': width
			.children("iframe").css
				'width': width
			parent.setTimeout ->
				p$("iframe", thickbox).css
					height: height + 100
				#.resize()
			, 1000

		checkExistingThickbox = (e) ->
			log "Start PTE..."
			#if (window.parent?.tb_remove?)
			#if window.parent isnt window
			if window.parent.frames.length > 0
				log "Modifying thickbox..."
				# Bind the current context (a href=...) so that thickbox
				# can act independent of me...
				do =>
					if not image_id?
						log "Error finding ID..."
						return
					#window.parent.setTimeout tb_click, 0
					window.parent.tb_click()
					# Set the correct width/height
					fixThickbox(window.parent)
					#$(window.parent.document).append(this).click()
					#$(this).appendTo($("body", window.parent.document)).unbind().click()
					true
				e.stopPropagation()
		# 
		# Entry to our code
		# Override the imgEdit.open function
		#
		injectPTE = ->
			if imageEdit.open?
				imageEdit.oldopen = imageEdit.open
				imageEdit.open = (id, nonce) ->
					image_id = id
					imageEdit.oldopen id,nonce
					launchPTE()
			true

		launchPTE = ->
			# Check if elements are loaded
			selector = """p[id^="imgedit-save-target-#{ image_id }"]"""
			$editmenu = $(selector)
			if $editmenu?.size() < 1
				window.log "Edit Thumbnail Menu not visible, waiting for #{ timeout }ms"
				window.setTimeout(launchPTE, timeout)
				return false

			# Add convenience functions to menu
			$editmenu.append $("""<a class="thickbox" href="#{ pte_url() }">#{ objectL10n.PTE }</a>""")
			.click checkExistingThickbox

		injectPTE()

