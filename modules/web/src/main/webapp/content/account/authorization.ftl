<#-- @ftlvariable name="showRememberMe" type="java.lang.Boolean" -->
<#include "/core.ftl">

<table class="account" cellspacing="0" cellpadding="0">
    <tr>
        <td class="item" nowrap="nowrap" valign="top">
            <div class="signin">
                <div class="title">
                    Вход в магазин
                </div>

                <form id="loginForm" method="post" action="/account/processing">
                    <table cellpadding="0" cellspacing="0" border="0">
                        <tr>
                            <td>
                                <label style="white-space: nowrap;"
                                       for="j_username">Ваш EMail адрес:</label>
                            </td>
                            <td>
                            <@bg.ui.input path="login.j_username" size="0"/>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <label style="white-space: nowrap;"
                                       for="j_password">Ваш пароль:</label>
                            </td>
                            <td>
                            <@bg.ui.input path="login.j_password" fieldType="password" size="0"/>
                            </td>
                        </tr>
                    <#if showRememberMe?? && showRememberMe>
                        <tr>
                            <td align="right" valign="middle"
                                style="text-align: right; vertical-align: middle;">
                                <@bg.ui.field path="login.rememberMe">
                                    <input type="checkbox" id="rememberMe" name="rememberMe" value="true"
                                           <#if bg.ui.statusValue=="true">checked="checked"</#if>/>
                                </@bg.ui.field>
                            </td>
                            <td align="left" valign="middle"
                                style="text-align: left; vertical-align: middle;">
                                <label for="rememberMe"><@message code="account.login.remember.label"/></label>
                            </td>
                        </tr>
                    <#else>
                        <tr>
                            <td colspan="2">
                                <input type="hidden" id="rememberMe" name="rememberMe" value="true"/>
                            </td>
                        </tr>
                    </#if>
                        <tr>
                            <td>
                                <button type="submit">Войти</button>
                            </td>
                            <td align="right" valign="bottom">
                                <div class="social-signin">
                                <#list ["facebook", "twitter", "vkontakte"] as p>
                                    <a class="social-signin-link" href="/account/social/start?provider=${p}"><i
                                            class="social-icon-24 social-icon-${p}"></i></a>
                                </#list>
                                </div>

                                <script type="application/javascript">
                                    $(".social-signin-link").click(function (event) {
                                        event.preventDefault();

                                        var link = $(this);
                                        var newWin = bg.ui.popupwindow(link.attr("href"), "BillionGoods: Авторизация", 500, 300);
                                        newWin.focus();

                                    });
                                </script>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <a id="recoveryLink"
                                   href="/account/recovery/request">Восстановить пароль</a>
                            </td>
                        </tr>
                    </table>
                </form>

            <#--
                        <form id="facebookLogin" action="/account/social/facebook" method="POST">
                            <input type="hidden" name="scope" value="offline_access"/>
                            <button type="submit">
                                <img src="/static/images/social/sign-in-with-facebook.png"/>
                            </button>
                        </form>
            -->
            </div>
        </td>

        <td>&nbsp;</td>

        <td class="item" width="100%" valign="top">
            <div>
                <div class="title">
                    Регистрация
                </div>

                <table>
                    <tr>
                        <td valign="top">
                            <div class="signin">
                                <form id="createForm" class="form" method="post" action="/account/create">
                                    <table>
                                        <tr>
                                            <td>
                                                <label style="white-space: nowrap;"
                                                       for="username">Ваше имя:</label>
                                            </td>
                                            <td>
                                            <@bg.ui.input path="registration.username" size="0"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label style="white-space: nowrap;"
                                                       for="email">EMail адрес:</label>
                                            </td>
                                            <td>
                                            <@bg.ui.input path="registration.email" size="0"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label style="white-space: nowrap;"
                                                       for="password">Пароль:</label>
                                            </td>
                                            <td>
                                            <@bg.ui.input path="registration.password" fieldType="password"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label style="white-space: nowrap;"
                                                       for="confirm">Подтверждение:</label>
                                            </td>
                                            <td>
                                            <@bg.ui.input path="registration.confirm" fieldType="password"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td></td>
                                            <td align="left">
                                                <button type="submit">Зарегистрироваться</button>
                                            </td>
                                        </tr>
                                    </table>
                                </form>
                            </div>
                        </td>

                        <td valign="top">
                            <div class="info">
                                <strong>Преимущества регистрации:</strong>
                                <ul>
                                    <li>- Просмотр всех ранее сделанных, а так же отложенных заказов;</li>
                                    <li>- Хранения товаров в корзине без ограничения по времени;</li>
                                    <li>- Управления адресами доставки и быстрый выбор адреса при оформление заказа;
                                    </li>
                                    <li>- а так же множество других преимуществ.</li>
                                </ul>
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
        </td>
    </tr>
</table>

<script type="text/javascript">
    $("#recoveryLink").click(function () {
        wm.util.url.redirect(wm.util.url.extend($(this).attr('href'), "email", $("#j_username").val(), true));
        return false;
    });
</script>
