<#-- @ftlvariable name="ordersSummary" type="billiongoods.server.services.payment.OrdersSummary" -->
<#-- @ftlvariable name="trackingSummary" type="billiongoods.server.web.servlet.mvc.maintain.form.TrackingSummary" -->
<#-- @ftlvariable name="exchangeManager" type="billiongoods.server.services.price.ExchangeManager" -->

<#include "/core.ftl"/>

<table>
    <tr>
        <td valign="top" nowrap="nowrap">
            <div class="exchange">
                <div class="caption">
                    <strong>Курс обмена</strong>
                </div>
                <form action="/maintain/exchange/update" method="post">
                    <input name="rate" value="${exchangeManager.exchangeRate?string("0.00")}">
                    <button>Обновить</button>
                </form>
            </div>
        </td>
        <td valign="top" rowspan="2" width="100%">
            <div style="padding-left: 5px">
                <div class="caption">
                    <strong>Текущие подписки</strong>
                </div>

            <#list trackingSummary.products as p>
                <table cellpadding="3" style="border-bottom: 1px dashed #808080">
                    <tr>
                        <td valign="top" rowspan="2" nowrap="nowrap">
                            <@bg.link.product p>${messageSource.getProductCode(p)}</@bg.link.product>
                        </td>
                        <td width="100%" style="overflow: hidden">
                            <@bg.link.product p>${p.name}</@bg.link.product>
                        </td>
                        <td valign="top" nowrap="nowrap">
                        ${p.price.amount?string("0.00")}<#if p.price.primordialAmount??>
                            (p.price.primordialAmount?string("0.00"))</#if>

                            <#assign stockInfo=p.stockInfo/>
                            <#if stockInfo.restockDate??>
                            ${messageSource.formatDate(stockInfo.restockDate, locale)}
                            <#elseif (stockInfo.leftovers??)>
                            ${stockInfo.leftovers}
                            <#else>
                                <strong>в наличии</strong>
                            </#if>
                        </td>
                    </tr>
                    <tr>
                        <#list trackingSummary.getProductTrackings(p) as t>
                            <td>${t.personId!t.personEmail}</td>
                            <td nowrap="nowrap">
                            ${t.trackingType.name()?substring(0, 1)}
                            ${messageSource.formatDate(t.registration, locale)}
                            </td>
                        </#list>
                    </tr>
                </table>
            </#list>
            </div>
        </td>
    </tr>

    <tr>
        <td valign="top" nowrap="nowrap">
            <div class="orders-summary" style="padding-top: 20px">
                <div class="caption">
                    <strong>Заказы</strong>
                </div>

                <table>
                <#list OrderState.values() as s>
                    <tr>
                        <td>
                            <a href="/maintain/order?state=${s.name()}">
                                    <@message code="order.status.${s.name()?lower_case}.label"/></label>
                            </a>
                        </td>
                        <td style="padding-left: 5px">
                            <a href="/maintain/order?state=${s.name()}">
                            ${ordersSummary.getOrdersCount(s)}
                            </a>
                        </td>
                    </tr>
                </#list>
                </table>
            </div>
        </td>
    </tr>
</table>
