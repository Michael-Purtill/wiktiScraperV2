<script>
    import * as _ from 'lodash';
    import { onMount } from 'svelte';
    
    
    let langInfo = [];
    let selectors = [];
    let lang = decodeURI(window.location.pathname.split("/")[2]);
    let word = window.location.pathname.split("/")[3];

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
        }
        else {
            let selectorsCopy = _.cloneDeep(selectors);
            selectorsCopy.push(id);
            selectors = selectorsCopy;
        }
    }

    function handleSubmit() {
        fetch("/api/testPageJsonHandler", {
            method: "POST",
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({selectors: selectors, lang: lang, word: word})
            
         }).then((res) => console.log(res));
    }

</script>

<div>
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
    <div class="langInfoContainer"><button on:click={handleSubmit}>Submit</button></div>
    
</div>

<style></style>