<#-- @ftlvariable name="form" type="billiongoods.server.web.servlet.mvc.maintain.form.ProductForm" -->
<#-- @ftlvariable name="attributes" type="billiongoods.server.warehouse.Attribute[]" -->
<#-- @ftlvariable name="priceConverter" type="billiongoods.server.services.price.PriceConverter" -->

<#-- @ftlvariable name="imageResourcesDomain" type="java.lang.String" -->

<#include "/core.ftl">

<script src="//cdn.ckeditor.com/4.4.6/full/ckeditor.js"></script>
<script type="text/javascript" src="<@bg.ui.static "js/jquery.ui.widget-1.10.3.js"/>"></script>
<script type="text/javascript" src="<@bg.ui.static "js/jquery.fileupload-8.6.1.js"/>"></script>

<div class="product-maintain" style="padding: 10px; border: 1px solid gray;">

    <form action="/maintain/product" method="post">
        <table style="width: 100%">
        <#if form.id?has_content>
            <#if form.productState != ProductState.ACTIVE>
                <tr id="inactiveWarning">
                    <td colspan="2" align="center" class="${form.productState.name()?lower_case}">
                        Внимание! Товар не в активном состоянии: ${form.productState.name()}
                    </td>
                </tr>
            </#if>
            <tr>
                <td valign="top"><label for="id">Артикул: </label></td>
                <td>
                    <@bg.ui.input path="form.id" fieldType="hidden">
                        <a href="/warehouse/product/${bg.ui.statusValue}"
                           target="_blank">${messageSource.getProductCode(bg.ui.actualValue)}</a>
                    </@bg.ui.input>
                </td>
            </tr>
        </#if>
            <tr>
                <td valign="top"><label for="categoryId">Категория: </label></td>
                <td>
                    <div id="categoryDiv">
                    <#if form.id??>
                        <div>
                            <#assign category=catalog.getCategory(form.categoryId)/>
                            <#list category.genealogy.parents as c>
                                <a href="/maintain/category?id=${c.id}" target="_blank">${c.name}</a> ->
                            </#list>
                            <a href="/maintain/category?id=${category.id}" target="_blank">${category.name}</a>

                            <a href="#" onclick="showCategoryEditor(); return false;">(изменить)</a>
                        </div>
                    </#if>

                        <div <#if form.id??>style="display: none"</#if>>
                        <@bg.ui.selectCategory "form.categoryId" catalog false>
                            <#if bg.ui.statusValue?has_content>(<a href="/maintain/category?id=${bg.ui.statusValue}"
                                                                   target="_blank">открыть в новом</a>)</#if>
                        </@bg.ui.selectCategory>
                        </div>
                    </div>
                </td>
            </tr>
            <tr>
                <td valign="top"><label for="name">Имя: </label></td>
                <td>
                <@bg.ui.field path="form.name">
                    <textarea id="${bg.ui.status.expression}" rows="4" style="width: 100%"
                              name="${bg.ui.status.expression}">${bg.ui.statusValue}</textarea>
                </@bg.ui.field>
                </td>
            </tr>
            <tr>
                <td valign="top"><label for="name">URL имя: </label></td>
                <td>
                <@bg.ui.field path="form.symbolic">
                    <textarea id="${bg.ui.status.expression}" rows="2" style="width: 100%;" readonly="readonly"
                              name="${bg.ui.status.expression}">${bg.ui.statusValue}</textarea>
                </@bg.ui.field>
                </td>
            </tr>
            <tr>
                <td valign="top"><label for="commentary">Коментарий: </label></td>
                <td>
                <@bg.ui.field path="form.commentary">
                    <textarea id="${bg.ui.status.expression}" rows="2" style="width: 100%"
                              name="${bg.ui.status.expression}">${bg.ui.statusValue}</textarea>
                </@bg.ui.field>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <hr>
                </td>
            </tr>
            <tr>
                <td><label for="weight">Вес: </label></td>
                <td><@bg.ui.input path="form.weight"/></td>
            </tr>
            <tr>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
            </tr>

            <tr>
                <td><label for="supplierPrice">Цена: </label></td>
                <td>
                <@bg.ui.input path="form.supplierPrice">USD</@bg.ui.input>
                <@bg.ui.input path="form.price" attributes="readonly='readonly'">руб</@bg.ui.input>
                </td>
            </tr>
            <tr>
                <td><label for="supplierPrimordialPrice">Цена до скидки: </label></td>
                <td>
                <@bg.ui.input path="form.supplierPrimordialPrice">USD</@bg.ui.input>
                <@bg.ui.input path="form.primordialPrice" attributes="readonly='readonly'">руб</@bg.ui.input>
                </td>
            </tr>

            <tr>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td><label for="stockCount">Количество: </label></td>
                <td><@bg.ui.input path="form.stockCount" value=0/></td>
            </tr>
            <tr>
                <td><label for="stockCount">Продано штук: </label></td>
                <td><@bg.ui.input path="form.stockSoldCount" value=0 attributes="readonly='readonly'"/></td>
            </tr>
            <tr>
                <td><label for="stockArrivalDate">Дата поставки: </label></td>
                <td><@bg.ui.input path="form.stockArrivalDate"/></td>
            </tr>
            <tr>
                <td><label for="stockShipDays">Доставка, дней: </label></td>
                <td><@bg.ui.input path="form.stockShipDays" value=3/></td>
            </tr>
            <tr>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td><label for="restriction">Ограничения: </label></td>
                <td>
                <@bg.ui.field path="form.restriction">
                    <select id="restriction" name="${bg.ui.status.expression}">
                        <option value="">Без ограничений</option>
                        <#list Restriction.values() as t>
                            <option value="${t.name()}"
                                    <#if bg.ui.statusValue=t>selected="selected"</#if>>${t.name()}</option>
                        </#list>
                    </select>
                </@bg.ui.field>
                </td>
            </tr>
            <tr>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td><label for="supplierReferenceCode">Код поставщика (SKU): </label></td>
                <td><@bg.ui.input path="form.supplierReferenceCode"/></td>
            </tr>
            <tr>
                <td valign="top"><label for="supplierReferenceId">Страница описания: </label></td>
                <td>
                <@bg.ui.input path="form.supplierReferenceId" size=90>
                    <#if bg.ui.statusValue?has_content>
                        (<a id="supplierReferenceLink"
                            href="http://www.banggood.com${bg.ui.statusValue}"
                            target="_blank">открыть в новом окне</a>)</#if>
                </@bg.ui.input>
                </td>
            </tr>
            <tr>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td valign="top"></td>
                <td>
                    <div id="supplierImages" style="display: none">
                        <div class="content"></div>
                        <div class="action">
                            <button id="selectSupplierImages" type="button">Установить выбранные</button>
                        </div>
                    </div>
                </td>
            </tr>
            <tr>
                <td valign="top"></td>
                <td>
                    <div id="supplierParameters" style="display: none">
                        <div class="content"></div>
                    </div>
                </td>
            </tr>
            <tr>
                <td valign="top"></td>
                <td align="right">
                    <div id="supplierInfo">
            <span class="action">
                <span><button type="button" onclick="loadSupplierDescription(); return false;">загрузить информацию
                </button></span>
                <span class="progress" style="display: none"></span>
            </span>
                    </div>
                </td>
            </tr>

        <#if form.categoryId??>
            <#assign category=catalog.getCategory(form.categoryId)/>

            <tr>
                <td colspan="2">
                    <hr>
                </td>
            </tr>

            <tr>
                <td valign="top"><label for="options">Опции: </label></td>
                <td>
                    <table id="optionsTable">
                        <@bg.ui.bind path="form.optionIds"/>
                        <#assign optionIds=bg.ui.status.actualValue!""/>

                        <@bg.ui.bind path="form.optionValues"/>
                        <#assign optionValues=bg.ui.status.actualValue!""/>

                        <#if optionIds?is_collection && (optionIds?size>0)>
                            <#list 0..(optionIds?size)-1 as i>
                                <#assign id=optionIds[i]/>
                                <#assign value=optionValues[i]/>
                                <tr>
                                    <td>
                                        <label for="option${id}" class="attribute">${id}</label>
                                        <input name="optionIds" type="hidden" value="${id}"/>
                                    </td>
                                    <td width="100%">
                                        <input style="width: 100%" id="option${id}" name="optionValues"
                                               value="${value}"/>
                                    </td>
                                    <td>
                                        <button class="remove" type="button">Удалить</button>
                                    </td>
                                </tr>
                            </#list>
                        </#if>
                        <tr id="optionControls">
                            <td></td>
                            <td colspan="2">
                                <button class="add" type="button">добавить</button>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <hr>
                </td>
            </tr>
            <tr>
                <td valign="top"><label for="viewImages">Состоит в группе: </label></td>
                <td>
                    <table id="groupsTable">
                        <@bg.ui.bind path="form.participatedNames"/>
                        <#assign participatedNames=bg.ui.status.actualValue!""/>

                        <@bg.ui.bind path="form.participatedGroups"/>
                        <#assign participatedGroups=bg.ui.status.actualValue!""/>

                        <#if participatedGroups?has_content>
                            <#list participatedGroups as g>
                                <#assign name=participatedNames[g_index]!""/>
                                <tr class="group">
                                    <td>
                                        <input type="hidden" name="participatedGroups" value="${g}">
                                        <a href="/maintain/group?id=${g}" target="_blank">#${g} ${name}</a>
                                    </td>
                                    <td>
                                        <button class="remove" type="button">Удалить</button>
                                    </td>
                                </tr>
                            </#list>
                        </#if>
                        <tr id="groupsControls">
                            <td></td>
                            <td>
                                <button class="add" type="button">Добавить в группу</button>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td valign="top"><label for="viewImages">Связана с группами: </label></td>
                <td>
                    <table id="relationshipsTable">
                        <@bg.ui.bind path="form.relationshipNames"/>
                        <#assign relationshipNames=bg.ui.status.actualValue!""/>

                        <@bg.ui.bind path="form.relationshipGroups"/>
                        <#assign relationshipGroups=bg.ui.status.actualValue!""/>

                        <@bg.ui.bind path="form.relationshipTypes"/>
                        <#assign relationshipTypes=bg.ui.status.actualValue!""/>

                        <#if relationshipGroups?has_content>
                            <#list relationshipGroups as r>
                                <#assign name=relationshipNames[r_index]!""/>
                                <#assign type=relationshipTypes[r_index]!""/>

                                <tr class="relationship">
                                    <td>
                                        <input name="relationshipTypes" type="hidden" value="${type.name()}">
                                        <@message code="relationship.${type.name()?lower_case}.label"/>
                                    </td>
                                    <td>
                                        <input name="relationshipGroups" type="hidden" value="${r}">
                                        <a href="/maintain/group?id=${r}" target="_blank">#${r} ${name}</a>
                                    </td>
                                    <td>
                                        <button class="remove" type="button">Удалить</button>
                                    </td>
                                </tr>
                            </#list>
                        </#if>
                        <tr id="relationshipsControls">
                            <td></td>
                            <td></td>
                            <td>
                                <button class="add" type="button">Связать с группой</button>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <hr>
                </td>
            </tr>
            <tr>
                <td valign="top"><label for="viewImages">Другие изображения: </label></td>
                <td>
                    <div class="images">
                        <@bg.ui.bind path="form.viewImages"/>
                        <#assign viewImages=bg.ui.status.actualValue!""/>

                        <@bg.ui.bind path="form.enabledImages"/>
                        <#assign enabledImages=bg.ui.status.actualValue!""/>

                        <@bg.ui.bind path="form.previewImage"/>
                        <#assign previewImage=bg.ui.status.actualValue!""/>

                        <#if viewImages?is_collection>
                            <#list viewImages as i>
                                <div class="image">
                                    <@bg.ui.productImage form i ImageSize.SMALL/>
                                    <label>
                                        <input name="enabledImages" type="checkbox" value="${i}"
                                               <#if enabledImages?contains(i)>checked="checked"</#if>/>
                                    </label>
                                    <label>
                                        <input name="previewImage" type="radio" value="${i}"
                                               <#if i==previewImage>checked="checked"</#if>/>
                                    </label>
                                </div>
                            </#list>
                        </#if>
                    </div>

                    <div>
                        <label for="fileupload">Добавить изображение</label>
                        <input id="fileupload" type="file" name="files[]" data-url="/maintain/product/upploadimg.ajax"
                               multiple>
                    </div>
                </td>
            </tr>
        </#if>
            <tr>
                <td colspan="2">
                    <hr>
                </td>
            </tr>
            <tr>
                <td valign="top"><label for="properties">Параметры: </label></td>
                <td>
                    <div id="productParameters">
                        <table>
                        <#list category.parameters as p>
                            <#assign attr=p.attribute/>
                            <#assign value=form.getProperty(attr)!""/>
                            <tr>
                                <td>
                                    <input type="hidden" name="propertyIds" value="${attr.id}">
                                    <label for="property${attr.id}" class="attribute">
                                        <a href="/maintain/attribute?id=${attr.id}">${attr.name}<#if attr.unit?has_content>
                                            ,
                                        ${attr.unit}</#if></a>
                                    </label>
                                </td>
                                <#if attr.attributeType == AttributeType.STRING>
                                    <td>
                                        <select id="property${attr.id}" name="propertyValues" style="width: 100%">
                                            <option value="">-- нет значения --</option>
                                            <#list p.values as v>
                                                <option value="${v}"<#if v==value>
                                                        selected="selected"</#if>>${v}</option>
                                            </#list>
                                        </select>
                                    </td>
                                    <td>
                                        <button type="button">Добавить</button>
                                    </td>
                                <#elseif attr.attributeType == AttributeType.BOOLEAN>
                                    <td>
                                        <select id="property${attr.id}" name="propertyValues" style="width: 100%">
                                            <option value="">-- нет значения --</option>
                                            <option value="false" <#if value="false">selected="selected"</#if>>нет
                                            </option>
                                            <option value="true" <#if value="true">selected="selected"</#if>>да</option>
                                        </select>
                                    </td>
                                    <td></td>
                                <#else>
                                    <td>
                                        <input id="property${attr.id}" name="propertyValues" value="${value}"
                                               style="width: 100%">
                                    </td>
                                    <td></td>
                                </#if>
                            </tr>
                        </#list>
                        </table>
                    </div>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <hr>
                </td>
            </tr>

            <tr>
                <td colspan="2">
                <@bg.ui.field path="form.description">
                    <label>
            <textarea style="width: 100%; min-height: 400px"
                      name="${bg.ui.status.expression}">${bg.ui.statusValue}</textarea>
                    </label>
                </@bg.ui.field>
                </td>
            </tr>

            <tr>
                <td colspan="2"><@bg.ui.spring.showErrors "br"/> </td>
            </tr>

            <tr>
                <td colspan="2">
                    <label for="productState">Состояние: </label>

                <@bg.ui.bind "form.productState"/>
                <#list ProductState.values() as s>
                    <button class="bg-ui-button<#if !bg.ui.actualValue?is_number && bg.ui.actualValue=s> selected</#if>"
                            type="submit"
                            name="${bg.ui.status.expression}" value="${s.name()}">${s.name()}</button>
                </#list>
                </td>
            </tr>
        </table>
    </form>
</div>

<#if form.id?has_content>
<div id="attributeValue" style="display: none; white-space: nowrap">
    <form>
        <input name="categoryId" value="${category.id}" type="hidden">
        <input name="attributeId" type="hidden">
        <label>
            <input name="value" style="width: 100%">
        </label>
    </form>
</div>
</#if>

<script type="application/javascript">
    window.onload = function () {
        CKEDITOR.plugins.addExternal('youtube', '<@bg.ui.static "js/ckeditor/plugins/youtube/"/>', 'plugin.js');

        CKEDITOR.replace('description', {
                    extraPlugins: 'youtube',
                    customConfig: '<@bg.ui.static "js/ckeditor/config.js"/>'
                }
        );
    };

    var colors = {
        'black': 'Черный',
        'blue': 'Синий',
        'green': 'Зеленый',
        'grey': 'Серый',
        'orange': 'Оранжевый',
        'light green': 'Светло-зеленый',
        'dark green': 'Темно-зеленый',
        'pink': 'Розовый',
        'purple': 'Пурпурный',
        'dark grey': 'Темно-серый',
        'light grey': 'Светло-серый',
        'apricot pink': 'Абрикосово-розовый',
        'grayish blue': 'Серовато-Синий',
        'peacock blue': 'Переливчатый-синий',
        'light pink': 'Светло-розовый',
        'dark blue': 'Темно-синий',
        'red': 'Красный',
        'rose red': 'Бордовый',
        'white': 'Белый',
        'yellow': 'Желтый',
        'peach': 'Персиковый',
        'silver': 'Серебряный',
        'gold': 'Золотой',
        'brown': 'Коричневый',
        'sky blue': 'Небесно-голубой',
        'olive green': 'Оливково-зеленый',
        'light orange': 'Небесно-голубой',
        'dark brown': 'Темно-коричневый',
        'grass blue': 'Бирюзовый',
        'light blue': 'Голубой',
        'light brown': 'Светло-коричневый',
        'golden': 'Золотой',
        'dark purple': 'Темно-пурпурный',
        'peach red': 'Красный персик',
        'beige': 'Бежевый'
    };

    var attributes = {
    <#list attributes as a>
        '${a.id}': {name: "${a.name}", unit: "${a.unit}"}<#if a_has_next>,</#if>
    </#list>
    };

    <#if form.id?has_content>
    var showCategoryEditor = function () {
        $("#categoryDiv>div").toggle();
    };

    var loadSupplierDescription = function () {
        var siEl = $("#supplierInfo");
        var supplierImagesEl = $("#supplierImages");
        var supplierParametersEl = $("#supplierParameters");
        var actionEl = siEl.find(".action span");

        actionEl.toggle();
        supplierImagesEl.hide();
        supplierParametersEl.hide();
        $.post("/maintain/product/loadSupplierInfo.ajax?id=${form.id}")
                .done(function (response) {
                    if (response.success) {
                        var data = response.data;

                        if (data.price != null) {
                            var supplierPrice = $("#supplierPrice");
                            if (data.price.amount == null) {
                                supplierPrice.val("");
                            } else {
                                supplierPrice.val(data.price.amount);
                            }

                            var supplierPrimordialPrice = $("#supplierPrimordialPrice");
                            if (data.price.primordialAmount == null) {
                                supplierPrimordialPrice.val("");
                            } else {
                                supplierPrimordialPrice.val(data.price.primordialAmount);
                            }

                            supplierPrice.trigger("change");
                            supplierPrimordialPrice.trigger("change");
                        }

                        if (data.stockInfo != null) {
                            var stockCount = $("#stockCount");
                            if (data.stockInfo.count == null) {
                                stockCount.val(0);
                            } else {
                                stockCount.val(data.stockInfo.count);
                            }
                            var stockSoldCount = $("#stockSoldCount");
                            if (data.stockInfo.soldCount == null) {
                                stockSoldCount.val(-1);
                            } else {
                                stockSoldCount.val(data.stockInfo.soldCount);
                            }

                            var stockShipDays = $("#stockShipDays");
                            if (data.stockInfo.shipDays == null) {
                                stockShipDays.val(0);
                            } else {
                                stockShipDays.val(data.stockInfo.shipDays);
                            }

                            var dt = data.stockInfo.arrivalDate;
                            var stockArrivalDate = $("#stockArrivalDate");
                            if (dt == null) {
                                stockArrivalDate.val();
                            } else {
                                stockArrivalDate.val(dt.year + "-" + ("0" + dt.monthValue).slice(-2) + "-" + ("0" + dt.dayOfMonth).slice(-2));
                            }

                            stockCount.trigger("change");
                            stockShipDays.trigger("change");
                            stockArrivalDate.trigger("change");
                        }

                        var imgsCnt = "<div id='supplierImagesList' style='text-align: left'>";
                        $.each(data.images, function (index, value) {
                            imgsCnt += "    <span style='white-space: nowrap'>";
                            imgsCnt += "        <input type='checkbox' checked=checked src='" + value + "'/>";
                            imgsCnt += "        <img src='" + value + "' width=45 height=45/>";
                            imgsCnt += "    </span>";
                        });


                        imgsCnt += "</div>";
                        supplierImagesEl.show().find(".content").html(imgsCnt);

                        var paramsCnt = "<table>";
                        $.each(data.parameters, function (key, value) {
                            paramsCnt += "  <tr>";
                            paramsCnt += "    <td><label>" + key + "</label></td>";

                            var vals = '';
                            $.each(value, function (i, v) {
                                var items = v.split('+');
                                $.each(items, function (i, v) {
                                    var cv = colors[v.toLowerCase()];
                                    vals += cv == undefined ? v : cv;
                                    if (i != items.length - 1) {
                                        vals += '+';
                                    }
                                });
                                if (i != value.length - 1) {
                                    vals += ';';
                                }
                            });
                            paramsCnt += "    <td>" + vals + "</td>";
                            paramsCnt += "  </tr>";
                        });
                        paramsCnt += "</table>";
                        supplierParametersEl.show().find(".content").html(paramsCnt);
                        actionEl.toggle();
                        bg.ui.unlock(actionEl);
                    } else {
                        actionEl.toggle();
                        bg.ui.unlock(actionEl, response.message, true);
                    }
                })
                .fail(function (jqXHR, textStatus, errorThrown) {
                    actionEl.toggle();
                    bg.ui.unlock(actionEl, "По техническим причинам сообщение не может быть отправлено в данный момент. " +
                    "Пожалуйста, попробуйте отправить сообщение позже.", true);
                });
    };

    var addOption = function () {
        var tr = $("<tr></tr>");

        var select = '<select name="optionIds">';
        $.each(attributes, function (key, value) {
            select += '<option value="' + key + '">' + value.name + ', ' + value.unit;
        });
        select += '</select>';

        var attrs = $("<td></td>").html(select);
        var values = $("<td></td>").html('<input name="optionValues" value=""/>');
        var remove = $("<td></td>").append($('<button type="button">Удалить</button>').click(removeOption));

        tr.append(attrs).append(values).append(remove).insertBefore($("#optionControls"));
    };

    var removeOption = function () {
        $(this).parent().parent().remove();
    };

    var addImage = function () {
        var tr = $("<tr></tr>");
        var values = $("<td></td>").html('<input name="viewImages" value=""/>');
        var remove = $("<td></td>").append($('<button type="button">Удалить</button>').click(removeImage));
        tr.append(values).append(remove).insertBefore($("#imagesControls"));
    };

    var removeImage = function () {
        $(this).parent().parent().remove();
    };

    var addGroup = function () {
        var tr = $("<tr></tr>");
        var values = $("<td></td>").html('<input name="participatedGroups" value=""/>');
        var remove = $("<td></td>").append($('<button class="remove" type="button">Удалить</button>').click(removeGroup));
        tr.append(values).append(remove).insertBefore($("#groupsControls"));
    };

    var removeGroup = function () {
        $(this).parent().parent().remove();
    };

    var addRelationship = function () {
        var tr = $("<tr></tr>");

        var select = '<select name="relationshipTypes">';
        <#list RelationshipType.values() as t>
            select += '<option value="${t.name()}"> <@message code="relationship.${t.name()?lower_case}.label"/>';
        </#list>
        select += '</select>';

        var attrs = $("<td></td>").html(select);
        var values = $("<td></td>").html('<input name="relationshipGroups" value=""/>');
        var remove = $("<td></td>").append($('<button type="button">Удалить</button>').click(removeRelationship));

        tr.append(attrs).append(values).append(remove).insertBefore($("#relationshipsControls"));
    };

    var removeRelationship = function () {
        $(this).parent().parent().remove();
    };
    </#if>

    var recalculatePrice = function (val) {
        if (val == '') {
            return val;
        }
        var v = parseFloat(val);
        return ${priceConverter.formula("v", "Math.round", MarkupType.REGULAR)};
    };

    $("#supplierPrice").change(function () {
        $("#price").val(recalculatePrice($(this).val()));
    });

    $("#supplierPrimordialPrice").change(function () {
        $("#primordialPrice").val(recalculatePrice($(this).val()));
    });

    var optionsTable = $("#optionsTable");
    optionsTable.find("button.add").click(addOption);
    optionsTable.find("button.remove").click(removeOption);

    var imagesTable = $("#imagesTable");
    imagesTable.find("button.add").click(addImage);
    imagesTable.find("button.remove").click(removeImage);

    var groupsTable = $("#groupsTable");
    groupsTable.find("button.add").click(addGroup);
    groupsTable.find("button.remove").click(removeGroup);

    var relationshipsTable = $("#relationshipsTable");
    relationshipsTable.find("button.add").click(addRelationship);
    relationshipsTable.find("button.remove").click(removeRelationship);

    $("#supplierReferenceId").change(function () {
        $("#supplierReferenceLink").attr('href', 'http://www.banggood.com' + $(this).val());
    });

    var insertProductImage = function (data) {
        var code = data.code;
        var uri = data.uri;

        var s = '';
        s += '<div class="image">';
        s += '<img src="${imageResourcesDomain}/' + uri.small + '"/>';
        s += '<input name="enabledImages" type="checkbox" value="' + code + '" checked="checked"/>';
        s += '<input name="previewImage" type="radio" value="' + code + '"/>';
        s += '</div>';

        $(".images").append($(s));
    };

    $(function () {
        $('#fileupload').fileupload({
            dataType: 'json',
            done: function (e, data) {
                insertProductImage(data.result.data);
            }
        });
    });

    var attributeValueDialog = $("#attributeValue");

    var addNewAttributeValue = function (attrId) {
        bg.ui.lock(null, "Добавление...");
        var serializeObject = attributeValueDialog.find('form').serializeObject();
        $.post("/maintain/category/parameterAddValue.ajax", JSON.stringify(serializeObject))
                .done(function (response) {
                    if (response.success) {
                        bg.ui.unlock(null, "Атрибут добавлен", false);
                        var value = serializeObject['value'];
                        $("#productParameters").find("#property" + attrId).append("<option value='" + value + "'>" + value + "</option>").val(value);
                    } else {
                        bg.ui.unlock(null, response.message, true);
                    }
                    attributeValueDialog.dialog("close");
                })
                .fail(function (jqXHR, textStatus, errorThrown) {
                    bg.ui.unlock(null, "По техническим причинам сообщение не может быть отправлено в данный момент. " +
                    "Пожалуйста, попробуйте отправить сообщение позже.", true);
                    attributeValueDialog.dialog("close");
                });
    };

    $("#productParameters").find("button").click(function () {
        var el = $(this).parent().parent();
        var attrId = el.find('input').val();
        attributeValueDialog.find("input[name=attributeId]").val(attrId);
        attributeValueDialog.dialog({
            title: 'Добавление нового значения',
            height: 'auto',
            width: 350,
            modal: true,
            buttons: {
                "Добавить": function () {
                    addNewAttributeValue(attrId);
                },
                "Отменить": function () {
                    $(this).dialog("close");
                }
            }
        });
    });

    $(".image img").click(function () {
        $(this).parent().find("input[name=previewImage]").prop('checked', 'checked');
    });

    $("#stockArrivalDate").datepicker({"dateFormat": "yy-mm-dd"}); // ISO 8601

    $("#name").change(function () {
        $.post("/maintain/product/symbolic.ajax?name=" + $(this).val())
                .done(function (response) {
                    if (response.success) {
                        $("#symbolic").val(response.data);
                    }
                })
                .fail(function (jqXHR, textStatus, errorThrown) {
                    bg.ui.unlock(null, "По техническим причинам сообщение не может быть отправлено в данный момент. " +
                    "Пожалуйста, попробуйте отправить сообщение позже.", true);
                });
    });

    $("#notAvailable").click(function () {
        $("#stockCount").val("0");
    });

    $("#available").click(function () {
        $("#stockCount").val("");
    });

    $("#selectSupplierImages").click(function () {
        bg.ui.lock(null, "Удаление изображений...");
        $.post("/maintain/product/clearimgs.ajax?id=" +${form.id})
                .done(function (response) {
                    if (response.success) {
                        $(".images").html('');
                        bg.ui.unlock(null, "Изображения удалены", false);
                    } else {
                        bg.ui.unlock(null, response.message, true);
                    }
                })
                .fail(function (jqXHR, textStatus, errorThrown) {
                    bg.ui.unlock(null, "По техническим причинам сообщение не может быть отправлено в данный момент. " +
                    "Пожалуйста, попробуйте отправить сообщение позже.", true);
                });

        bg.ui.lock(null, "Добавление изображений");
        var urls = [];
        var find = $("#supplierImagesList").find("input:checked");
        find.each(function (index, input) {
            urls[index] = $(input).attr('src');
        });
        $.post("/maintain/product/loadimgs.ajax?id=" +${form.id}, JSON.stringify(urls))
                .done(function (response) {
                    if (response.success) {
                        $.each(response.data, function (index, value) {
                            if (value.body.success) {
                                insertProductImage(value.body.data);
                            }
                        });
                        bg.ui.unlock(null, "Изображения добавлены", false);
                    } else {
                        bg.ui.unlock(null, response.message, true);
                    }
                })
                .fail(function (jqXHR, textStatus, errorThrown) {
                    bg.ui.unlock(null, "По техническим причинам сообщение не может быть отправлено в данный момент. " +
                    "Пожалуйста, попробуйте отправить сообщение позже.", true);
                });

    });
</script>