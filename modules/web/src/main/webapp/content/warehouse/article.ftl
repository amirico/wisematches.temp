<#-- @ftlvariable name="article" type="billiongoods.server.warehouse.Article" -->

<#include "/core.ftl">

<div class="article">
    <div class="image">
    <@bg.ui.articleImg article article.previewImageId!"" ImageType.PREVIEW 230/>
    </div>
    <div class="name">${article.name}</div>
    <div class="price"><@bg.ui.price article.price/></div>

    <div class="description">
    ${article.description!""}
    </div>

    <table>
    <#list article.properties as p>
        <tr>
            <td>${p.attribute.name}</td>
            <td>${p.value} ${p.attribute.unit}</td>
        </tr>
    </#list>
    </table>

    <table>
    <#list article.options as o>
        <tr>
            <td>${o.attribute.name}</td>
            <td><#list o.values as v>${v} | </#list></td>
        </tr>
    </#list>
    </table>


    <table>
    <#list article.accessories as a>
        <tr>
            <td><@bg.link.article {"id": a}>Accessory id: ${a}</@bg.link.article></td>
        </tr>
    </#list>
    </table>
</div>