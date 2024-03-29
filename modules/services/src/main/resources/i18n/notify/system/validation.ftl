<#-- @ftlvariable name="context" type="billiongoods.server.services.validator.ValidationSummary" -->

<style type="text/css">
    table.info th {
        vertical-align: bottom;
        font-weight: bold;
        border: 1px solid #808080;
        border-collapse: collapse;
    }

    table.info td {
        vertical-align: top;
        border-bottom: 1px dotted #d3d3d3;
        border-collapse: collapse;
    }
</style>

<#macro stockInfo info>
${info.stockState.name()} / ${info.shipDays} (${info.count})
    <#if info.arrivalDate??>
    <br>
    (${messageSource.formatDate(info.arrivalDate, locale)})
    </#if>
</#macro>

<#macro priceInfo price>
${price.amount?string("0.00")} (<#if price.primordialAmount??>${price.primordialAmount?string("0.00")}<#else>-</#if>)
</#macro>

<table>
    <tr>
        <td>Запущено:</td>
        <td><#if context.startDate??>${context.startDate?datetime?string}<#else>Проверка не
            проводилась</#if></td>
    </tr>
    <tr>
        <td>Завершено:</td>
        <td><#if context.finishDate??>${context.finishDate?datetime?string}<#else>В процессе</#if></td>
    </tr>
    <tr>
        <td>Проверено:</td>
        <td>${context.processedProducts} из ${context.totalCount}</td>
    </tr>
    <tr>
        <td>Ошибок:</td>
        <td>${context.brokenProducts?size}</td>
    </tr>
    <tr>
        <td>Потеряно:</td>
        <td>${context.lostProducts?size}</td>
    </tr>
    <tr>
        <td>Обновлено:</td>
        <td>${context.updatedProducts?size}</td>
    </tr>
    <tr>
        <td>Без изменений:</td>
        <td>${context.processedProducts - context.updatedProducts?size - context.brokenProducts?size - context.lostProducts?size}</td>
    </tr>
</table>

<br><br>

<#if context.lostProducts?has_content>
<div>
    Удаленные продукты:
    <table class="info">
        <tr>
            <th>Артикул</th>
            <th>Наименование</th>
            <th>Banggood</th>
            <th>Текущая цена</th>
            <th>Цена до скидки</th>
        </tr>

        <#list context.lostProducts as b>
            <tr>
                <td nowrap="nowrap">
                    <a href="http://www.billiongoods.ru/maintain/product?id=${b.id}">${messageSource.getProductCode(b.id)}</a>
                </td>
                <td>
                ${b.name}
                </td>
                <td nowrap="nowrap">
                    <a href="${b.supplierInfo.referenceUrl.toString()}">${b.supplierInfo.referenceCode}</a>
                </td>
                <td nowrap="nowrap">
                ${b.price.amount?string("0.00")}
                </td>
                <td nowrap="nowrap">
                    <#if b.price.primordialAmount??>${b.price.primordialAmount?string("0.00")}</#if>
                </td>
            </tr>
        </#list>
    </table>
</div>
</#if>

<br>

<#if context.brokenProducts?has_content>
<div>
    Ошибки при проверки:
    <table class="info">
        <tr>
            <th>Артикул</th>
            <th>Наименование</th>
            <th>Banggood</th>
            <th>Текущая цена</th>
            <th>Цена до скидки</th>
            <th>Наличие</th>
        </tr>

        <#list context.brokenProducts as b>
            <tr>
                <td nowrap="nowrap">
                    <a href="http://www.billiongoods.ru/maintain/product?id=${b.id}">${messageSource.getProductCode(b.id)}</a>
                </td>
                <td>
                ${b.name}
                </td>
                <td>
                    <a href="${b.supplierInfo.referenceUrl.toString()}">${b.supplierInfo.referenceCode}</a>
                </td>
                <td nowrap="nowrap">
                ${b.price.amount?string("0.00")}
                </td>
                <td nowrap="nowrap">
                    <#if b.price.primordialAmount??>${b.price.primordialAmount?string("0.00")}</#if>
                </td>
                <td nowrap="nowrap">
                    <@stockInfo b.stockInfo/>
                </td>
            </tr>
        </#list>
    </table>
</div>
</#if>

<br>

<#if context.updatedProducts?has_content>
<div>
    Обновленные товары:
    <table class="info">
        <tr>
            <th rowspan="2">Артикул</th>
            <th colspan="3">Цена (до скидки)</th>
            <th colspan="2">Наличие</th>
        </tr>

        <tr>
            <th>Старая</th>
            <th>Новая</th>
            <th>Изменение</th>
            <th>Старое</th>
            <th>Новое</th>
        </tr>

        <#list context.updatedProducts as v>
            <tr>
                <td>
                    <a href="http://www.billiongoods.ru/warehouse/product/${v.product.id}">${messageSource.getProductCode(v.product.id)}</a>
                </td>
                <#if v.oldPrice.equals(v.newPrice)>
                    <td colspan="3">
                        <@priceInfo v.oldPrice/>
                    </td>
                <#else>
                    <td>
                        <@priceInfo v.oldPrice/>
                    </td>
                    <td>
                        <#if v.newPrice??>
                            <@priceInfo v.newPrice/>
                        <#else>
                            не загрузилась
                        </#if>
                    </td>
                    <td>
                    ${(v.newPrice.amount - v.oldPrice.amount)?string("0.00")}
                        (<#if !v.oldPrice.primordialAmount?? && !v.newPrice.primordialAmount??>
                        -
                    <#elseif !v.oldPrice.primordialAmount??>
                        +${v.newPrice.primordialAmount?string("0.00")}
                    <#elseif !v.newPrice.primordialAmount??>
                    ${v.oldPrice.primordialAmount?string("0.00")}
                    <#else>
                    ${(v.newPrice.primordialAmount - v.oldPrice.primordialAmount)?string("0.00")}
                    </#if>)
                    </td>
                </#if>

                <#if v.oldStockInfo.equals(v.newStockInfo)>
                    <td colspan="2">
                        <@stockInfo v.oldStockInfo/>
                    </td>
                <#else>
                    <td>
                        <@stockInfo v.oldStockInfo/>
                    </td>
                    <td>
                        <#if v.newStockInfo??>
                            <@stockInfo v.newStockInfo/>
                        <#else>
                            не загрузилась
                        </#if>
                    </td>
                </#if>
            </tr>
        </#list>
    </table>
</div>
</#if>