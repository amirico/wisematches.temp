<#-- @ftlvariable name="category" type="billiongoods.server.warehouse.Category" -->
<#-- @ftlvariable name="filter" type="billiongoods.server.warehouse.ProductFilter" -->
<#-- @ftlvariable name="filtering" type="billiongoods.server.warehouse.Filtering" -->
<#-- @ftlvariable name="pageableForm" type="billiongoods.server.web.servlet.mvc.warehouse.form.ProductsPageableForm" -->

<#include "/core.ftl"/>

<#--================ Filtering based on data defined for products ======================-->
<#macro enumValueElement a v c>
    <#if v?has_content>
    <li class="item">
        <input id="parameter_${a.id}_${v}" type="checkbox" name="${a.id}" value="${v}"
               <#if filter?? && filter.getValue(a)?? && filter.getValue(a).isAllowed(v)>checked="checked"</#if> />
        <label for="parameter_${a.id}_${v}">
        ${v} <span class="count">(${c})</span>
        </label>
    </li>
    </#if>
</#macro>

<#macro categoryAttributeEnum a item>
    <#assign splitCount=5/>
    <#if item.values?size<8>
        <#assign splitCount=7/>
    </#if>
<ul>
    <#list item.values as v>
        <#if (v_index<splitCount)><@enumValueElement a v item.getValueCount(v)/></#if>
    </#list>
</ul>
    <#if (item.values?size>splitCount)>
    <div class="others" style="display: none">
        <ul>
            <#list item.values as v>
                <#if (v_index>=splitCount)>
                <@enumValueElement a v item.getValueCount(v)/>
            </#if>
            </#list>
        </ul>
    </div>
    <span class="pseudolink fulllist">Показать еще</span>
    </#if>
</#macro>

<#macro categoryAttributeInteger a item>
    <#assign minTotal=item.min/>
    <#assign maxTotal=item.max/>

    <#assign min=minTotal>
    <#assign max=maxTotal>
    <#if filter?? && filter.hasValue(a)>
        <#assign v=filter.getValue(a)/>
        <#assign min=v.min/>
        <#assign max=v.max/>
    </#if>

<ul class="ui-slider-container">
    <li>
        <label>
            <input id="parameter_${a.id}_min" name="${a.id}" class="slider_min_input" value="${min}">
        </label>
        —
        <label>
            <input id="parameter_${a.id}_max" name="${a.id}" class="slider_max_input" value="${max}">
        </label>
    ${a.unit!""}
    </li>

    <li>
        <div class="ui-slider-bar">
            <span class="ui-slider-min">${minTotal}</span>
            <span class="ui-slider-med">${minTotal + (maxTotal-minTotal)/2?round}</span>
            <span class="ui-slider-max">${maxTotal}</span>
        </div>
    </li>
</ul>
</#macro>

<#macro categoryAttributeBoolean a item>
<ul>
    <li class="item">
        <input id="parameter_${a.id}_yes" type="radio" name="${a.id}" value="true"
               <#if filter?? && filter.getValue(a)?? && filter.getValue(a).isAllowed(true)>checked="checked"</#if>/>
        <label for="parameter_${a.id}_yes">
            Да <span class="count">(${item.getValueCount(true)})</span>
        </label>
    </li>
    <li class="item">
        <input id="parameter_${a.id}_no" type="radio" name="${a.id}" value="false"
               <#if filter?? && filter.getValue(a)?? && filter.getValue(a).isAllowed(false)>checked="checked"</#if>/>
        <label for="parameter_${a.id}_no">
            Нет <span class="count">(${item.getValueCount(false)})</span>
        </label>
    </li>
    <li class="item">
        <input id="parameter_${a.id}" class="default" type="radio" name="${a.id}" value=""
               <#if !filter?? || !filter.getValue(a)??>checked="checked"</#if>/>
        <label for="parameter_${a.id}">Неважно</label>
    </li>
</ul>
</#macro>

<#if category?? && filtering?? && pageableForm??>
<div id="productsFilterForm" class="filtering">
    <#assign minTotalPrice=(filtering.minPrice/10)?floor*10>
    <#assign maxTotalPrice=(filtering.maxPrice/10)?ceiling*10>

    <#assign minPrice=minTotalPrice>
    <#assign maxPrice=maxTotalPrice>
    <#if filter?? && filter.minPrice??>
        <#assign minPrice=(filter.minPrice/10)?floor*10>
    </#if>

    <#if filter?? && filter.maxPrice??>
        <#assign maxPrice=(filter.maxPrice/10)?ceiling*10>
    </#if>

    <div class="property">
        <div class="name">
            Цена
        </div>

        <div class="items">
            <ul class="ui-slider-container">
                <li>
                    <label>
                        <input name="minPrice" class="slider_min_input" value="${minPrice}">
                    </label>
                    —
                    <label>
                        <input name="maxPrice" class="slider_max_input" value="${maxPrice}">
                    </label>
                    руб.
                </li>

                <li>
                    <div class="ui-slider-bar">
                        <span class="ui-slider-min">${minTotalPrice}</span>
                        <span class="ui-slider-med">${minTotalPrice + (maxTotalPrice-minTotalPrice)/2?round}</span>
                        <span class="ui-slider-max">${maxTotalPrice}</span>
                    </div>
                </li>
            </ul>
        </div>

        <#list filtering.filteringItems as i>
            <#if !i.empty>
                <#assign a = i.attribute/>
                <div class="property">
                    <div class="name">
                    ${a.name}<#if a.unit?has_content>, ${a.unit}</#if>
                        <#if filter??>
                            <span class="clean">
                        <span class="pseudolink reset" <#if !filter.hasValue(a)>style="display: none"</#if>>Сбросить фильтр</span>
                    </span>
                        </#if>
                    </div>

                    <div class="items">
                        <#switch a.attributeType>
                        <#case AttributeType.STRING><@categoryAttributeEnum a i/><#break>
                            <#case AttributeType.INTEGER><@categoryAttributeInteger a i/><#break>
                            <#case AttributeType.BOOLEAN><@categoryAttributeBoolean a i/><#break>
                        </#switch>
                    </div>
                </div>
            </#if>
        </#list>

        <#if filter?? && !filter.empty>
            <div style="text-align: right">
                <button id="resetFilterButton" type="button">Сбросить фильтр</button>
            </div>
        </#if>
    </div>

    <script type="text/javascript">
        new bg.warehouse.Filter(${minTotalPrice}, ${maxTotalPrice}, ${minPrice}, ${maxPrice},
                '<@bg.ui.tableNavigationParams pageableForm "filter" ""/>');
    </script>
</#if>
