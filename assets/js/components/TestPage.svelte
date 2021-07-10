<script>
    import * as _ from 'lodash';
    import { onMount } from 'svelte';
    
    
    let langInfo = [];
    let selectors = [];
    let lang = decodeURI(window.location.pathname.split("/")[2]);
    let word = window.location.pathname.split("/")[3];
    let wikiLink = "https://en.wiktionary.org/wiki/" + word + "#" + lang;
    let wordClass = window.location.pathname.split("/")[4];
    let fields = [];

    onMount(async () => {
        console.log(lang, word);

        fetch("/api/wordInfo/" + `${lang}/${word}`).then((r) => {return r.json()}).then((d) => {langInfo = d })
    });

    function handleClick(e) {
        var id = e.target.id;
        if (e.target.localName == "li") {
            id = e.target.parentElement.id;
        }
        if (_.includes(selectors, id)) {
            selectors = _.filter(selectors, s => s != id)
            fields = _.filter(fields, f => f.id != id);
        }
        else {
            let selectorsCopy = _.cloneDeep(selectors);
            selectorsCopy.push(id);
            selectors = selectorsCopy;
        }
    }

    function handleSubmit() {
        debugger;
        fetch("/api/testPageJsonHandler", {
            method: "POST",
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({selectors: selectors, lang: lang, word: word})
            
         }).then((res) => console.log(res));
    }

    function handleFieldChange(id, e) {
        let val = e.target.value;
        
        let fieldsClone = _.cloneDeep(fields);

        var idIndex = _.findIndex(fields, function(f) {return f.id == id});

        if (idIndex == -1) {
            fieldsClone.push({id: id, val: val});
        }
        else {
            fieldsClone[idIndex] = {id: id, val: val};
        }

        fields = fieldsClone;
    }

    function submitSelectors() {
        fields;
        lang;
        wikiLink;

        fetch("/api/uploadTemplate", {
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            method: "POST", body: JSON.stringify({selectors: fields, wikiLink: wikiLink, lang: lang, wordClass: wordClass})}).then(() => window.close());
    }

    function handleClassChange(e) {
        wordClass = e.target.value;
    }

    function handleKeyPress(e) {
        if (e.keyCode == 13) {
            submitSelectors();
        }
    }

</script>

<div>
    <a class="wikiLink" href={wikiLink} target="_blank">View on Wiktionary</a>
    {#each langInfo as datum, i}
        <div class="langInfoContainer">
            <h3>{datum.title.replaceAll("[ edit ]", "").replaceAll("[edit]", "").replaceAll("  ", " ").replaceAll(" ,", ",").replaceAll(" .", ".")}</h3>
            {#each datum.content as content, j}
                {#if content.tag == "p"}
                <p id={`${i}:${j}`} class={_.includes(selectors, `${i}:${j}`) ? "selected" : null} on:click={handleClick}>{content.innerContent.replaceAll("\n", "").replaceAll("  ", " ").replaceAll(" ,", ",").replaceAll(" .", ".")}</p>
                {:else if content.tag == "ul" || content.tag == "ol"}
                <ul class={_.includes(selectors, `${i}:${j}`) ? "selected" : null} id={`${i}:${j}`} on:click={handleClick}>
                    {#each content.innerContent as innerContent}
                        <li>{innerContent.replaceAll("\n", "").replaceAll("  ", " ").replaceAll(" ,", ",").replaceAll(" .", ".")}</li>
                    {/each}
                </ul>
                {:else if content.tag == "table"}
                <table>
                    <tbody>
                        {#each content.innerContent as innerContent, k}
                            <tr>
                                {#each innerContent as inner, l}
                                    <td class={_.includes(selectors, `${i}:${j}:${k}:${l}`) ? "selected" : null} rowspan={inner.rowspan} colspan={inner.colspan} id={`${i}:${j}:${k}:${l}`} on:click={handleClick}>{inner.text.replaceAll("\n", "").replaceAll("  ", " ").replaceAll(" ,", ",").replaceAll(" .", ".")}</td>
                                {/each}
                            </tr>
                        {/each}
                    </tbody>
                </table>

                {:else if content.tag == "tables"}
                    {#each content.innerContent as tableArr, k}
                        <table>
                            <tbody>
                                {#each tableArr as trow, l}
                                    <tr>
                                        {#each trow as tcol, m}
                                        <td class={_.includes(selectors, `${i}:${j}:${k}:${l}:${m}`) ? "selected" : null} id={`${i}:${j}:${k}:${l}:${m}`} rowspan={tcol.rowspan} colspan={tcol.colspan} on:click={handleClick}>{tcol.text.replaceAll("\n", "").replaceAll("  ", " ").replaceAll(" ,", ",").replaceAll(" .", ".")}</td>
                                        {/each}
                                    </tr>
                                {/each}
                            </tbody>
                        </table>
                    {/each}
                {/if}
            {/each}
        </div>
    {/each}
    
    <div class={(selectors.length > 0 ? "showDataSubber" : "hideDataSubber") + " langInfoContainer"}>
        <div class="fields">
            <h3>Word Class</h3>
            <input on:change={handleClassChange} type="text" value={wordClass}/>
        </div>
        {#each selectors as s}
            <div class="fields">
                <h4>{document.getElementById(s).innerText}</h4>
                <input id={"field" + s} on:keypress={handleKeyPress} on:keyup={(e) => handleFieldChange(s, e)} type="text" placeholder="Field Name" value={document.getElementById(s).id.split(":").length == 4 ? document.getElementById(s).parentElement.children[0].innerText + "_" + document.getElementById(s).parentElement.parentElement.children[0].children[document.getElementById(s).id.split(":")[3]].innerText : ""} />
            </div>
        
        {/each}

        <button on:click={submitSelectors}>Submit</button>

    </div>
</div>

<style></style>